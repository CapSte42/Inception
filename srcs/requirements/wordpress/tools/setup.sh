#!/bin/bash

set -e

echo "[INFO] Waiting for MariaDB to be ready..."
until mariadb-admin ping -h"$DB_HOST" --silent; do
    sleep 1
done

# 👉 Scarica WP solo se non è già presente
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "[INFO] Downloading WordPress..."
    wp core download --allow-root
else
    echo "[INFO] WordPress already downloaded."
fi

# 👉 Configura wp-config.php solo se non esiste
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "[INFO] Creating wp-config.php..."
    wp config create --allow-root \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=$DB_HOST \
        --path='/var/www/html'
fi

# 👉 Installa WordPress solo se non è già installato
if ! wp core is-installed --allow-root; then
    echo "[INFO] Installing WordPress..."
    wp core install --allow-root \
        --url=$WP_URL \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_MAIL
else
    echo "[INFO] WordPress already installed."
fi
