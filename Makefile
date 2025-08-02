# =================== CONFIGURAZIONE =====================
SHELL := /bin/bash

ENV_FILE := srcs/.env
COMPOSE_FILE := srcs/docker-compose.yml

ifeq ($(wildcard $(ENV_FILE)),)
$(error $(ENV_FILE) does not exist)
endif
ifeq ($(wildcard $(COMPOSE_FILE)),)
$(error $(COMPOSE_FILE) does not exist)
endif

# =================== LETTURA VARIABILI DA .env ======================
DOMAIN_NAME            := $(shell grep '^DOMAIN_NAME=' $(ENV_FILE) | cut -d= -f2)
MARIADB_VOLUME_PATH    := $(shell grep '^MARIADB_VOLUME_PATH=' $(ENV_FILE) | cut -d= -f2)
WORDPRESS_VOLUME_PATH  := $(shell grep '^WORDPRESS_VOLUME_PATH=' $(ENV_FILE) | cut -d= -f2)
VOLUME_PATHS           := $(MARIADB_VOLUME_PATH) $(WORDPRESS_VOLUME_PATH)

CRT_PATH = srcs/requirements/nginx/ssl/$(DOMAIN_NAME).crt
KEY_PATH = srcs/requirements/nginx/ssl/$(DOMAIN_NAME).key

SSL_DIR := srcs/requirements/nginx/ssl

NGINX_CONF_TEMPLATE := srcs/requirements/nginx/conf/nginx.conf.template
NGINX_CONF := srcs/requirements/nginx/conf/nginx.conf

DOCKER_COMPOSE := docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

# =================== TARGETS ============================
.PHONY: all setup build up down stop ps logs \
	clean fclean re re-interactive \
	gen-cert delete-cert show-env tree generate-nginx-conf help

# === DEFAULT: Avvia lo stack ===
all: up

# === Genera nginx.conf da template usando DOMAIN_NAME ===
generate-nginx-conf:
	sed "s|__DOMAIN_NAME__|$(DOMAIN_NAME)|g" $(NGINX_CONF_TEMPLATE) > $(NGINX_CONF)
	@echo "[+] nginx.conf generato con DOMAIN_NAME=$(DOMAIN_NAME)"

# === Crea directory per volumi persistenti e genera nginx.conf ===
setup: generate-nginx-conf
	mkdir -p $(VOLUME_PATHS)

# === Build immagini senza cache ===
build: setup
	$(DOCKER_COMPOSE) build --no-cache

# === Avvia container in background ===
up: setup
	$(DOCKER_COMPOSE) up -d

# === Avvia container in foreground (mostra log live) ===
up-interactive: setup
	$(DOCKER_COMPOSE) up

# === Ferma e rimuove container (senza volumi/images) ===
down:
	$(DOCKER_COMPOSE) down

# === Solo stop ===
stop:
	$(DOCKER_COMPOSE) stop

# === Stato container ===
ps:
	$(DOCKER_COMPOSE) ps

# === Log dei servizi ===
logs:
	$(DOCKER_COMPOSE) logs

# === Clean: ferma e rimuove container/network (ma lascia volumi) ===
clean: down

# === Full clean: elimina volumi persistenti ===
fclean: clean
	@echo "[+] Deleting local volumes..."
	@sudo rm -rf $(VOLUME_PATHS) || echo "[!] Permission denied or already deleted."

# === Ricostruzione totale ===
re: fclean build up

# === Ricostruzione totale (modalità interactive) ===
re-interactive: fclean build up-interactive

# === Forza la generazione di certificati SSL self-signed ===
gen-cert:
	mkdir -p $(SSL_DIR)
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout $(KEY_PATH) \
	-out $(CRT_PATH) \
	-subj "/C=IT/ST=Italy/L=Firenze/O=42/OU=42/CN=$(DOMAIN_NAME)"
	@echo "[+] Certificati generati in $(SSL_DIR)"

# === Cancella certificati ===
delete-cert:
	rm -f $(CRT_PATH) $(KEY_PATH)
	@echo "[+] Certificati rimossi (se presenti)."

# === Mostra tutte le variabili correnti ===
show-env:
	@echo "--- VARIABILI DAL .env ---"
	@cat $(ENV_FILE)

# === Visualizza la struttura delle directory del progetto ===
tree:
	@echo "--- STRUTTURA PROGETTO ---"
	@find . -type d | sort
	@echo "--- FINE ---"

# === AIUTO ===
help:
	@echo ""
	@echo "********* GUIDA RAPIDA: PRIMA E SUCCESSIVE ACCENSIONI *********"
	@echo ""
	@echo "AVVIO **PER LA PRIMA VOLTA** (o dopo fclean):"
	@echo "  1. make gen-cert          # Genera certificati SSL self-signed per Nginx"
	@echo "  2. make build             # Build delle immagini (setup automatico volumi e nginx.conf)"
	@echo "  3. make up                # Avvia i container in background"
	@echo "    oppure: make up-interactive  # Per vederli in foreground"
	@echo ""
	@echo "RIAVVIO SUCCESSIVO (es. dopo un reboot, senza cancellare volumi):"
	@echo "  make up                   # Avvia direttamente i container"
	@echo ""
	@echo "REBUILD TOTALE (forza wipe di TUTTO: volumi, immagini, dati):"
	@echo "  make re                   # Full clean, build, up"
	@echo ""
	@echo "ALTRE OPERAZIONI UTILI:"
	@echo "  make down                 # Ferma e rimuove container/network"
	@echo "  make stop                 # Stoppa solo i container"
	@echo "  make clean                # Down + lascia volumi"
	@echo "  make fclean               # Clean + elimina volumi locali"
	@echo "  make logs                 # Log live dei container"
	@echo "  make ps                   # Stato container"
	@echo "  make generate-nginx-conf  # Rigenera nginx.conf da template (.env > conf)"
	@echo "  make show-env             # Mostra le variabili da .env"
	@echo "  make tree                 # Visualizza struttura progetto"
	@echo ""
	@echo "NOTE:"
	@echo " - Cambi il dominio in .env? Ricorda di fare:"
	@echo "       make generate-nginx-conf"
	@echo "   E (se serve) rigenerare i certificati:"
	@echo "       make gen-cert"
	@echo ""
	@echo " - Il file nginx.conf viene generato AUTOMATICAMENTE a ogni build/setup"
	@echo ""
	@echo "***************************************************************"
	@echo ""
