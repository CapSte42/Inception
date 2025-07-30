#--------------------------------------
#     MAKEFILE PER INCEPTION
#--------------------------------------

NAME=inception
SRC_DIR=srcs
DC=docker compose -f $(SRC_DIR)/docker-compose.yml

#--------------------------------------
#     COLORI
#      - INFO  (verde)
#      - WARN  (giallo)
#      - ERROR (rosso)
#--------------------------------------

GREEN=\033[0;32m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m

#--------------------------------------
# TARGET PREDEFINITO
#--------------------------------------
all: up

#------------------- UP ---------------
# Builda e avvia tutti i container in modalità detached.
#--------------------------------------
up:
	@echo -e "$(GREEN)[INFO] Building and starting containers...$(NC)"
	@$(DC) up -d --build

#------------------- DOWN -------------
# Ferma tutti i container definiti nel progetto.
#--------------------------------------
down:
	@echo -e "$(YELLOW)[WARN] Stopping containers...$(NC)"
	@$(DC) down

#------------------- CLEAN ------------
# Ferma i container e rimuove anche i volumi associati.
#--------------------------------------
clean:
	@echo -e "$(YELLOW)[WARN] Stopping containers and removing volumes...$(NC)"
	@$(DC) down --volumes

#------------------- FCLEAN -----------
# Pulisce tutto e in più forza la rimozione
# di tutte le immagini Docker presenti nel sistema.
#--------------------------------------
fclean: clean
	@echo -e "$(RED)[DANGER] Removing all Docker images...$(NC)"
	@docker rmi -f $$(docker images -q) || true

#------------------- RE ---------------
# Ricostruisce completamente il progetto:
# fclean seguito da up.
#--------------------------------------
re: fclean up

#------------------- PS ---------------
# Mostra lo stato attuale dei container attivi.
#--------------------------------------
ps:
	@$(DC) ps

#------------------- LOGS -------------
# Mostra i log statici dei container.
#--------------------------------------
logs:
	@echo -e "$(GREEN)[INFO] Showing logs ...$(NC)"
	@$(DC) logs

#------------------- LOGS-F -----------
# Mostra i log in tempo reale.
# Ctrl+C per interrompere.
#--------------------------------------
logs-f:
	@echo -e "$(GREEN)[INFO] Tailing logs live (colorized)... Press Ctrl+C to stop.$(NC)"
	@$(DC) logs --follow
#------------------- PRUNE ------------
# rimuove TUTTO ciò che non è in uso,
# incluse immagini orfane, container stoppati e volumi inutilizzati.
#--------------------------------------
prune:
	@echo -e "$(RED)[DANGER] Pruning unused Docker data...$(NC)"
	@docker system prune -af --volumes
