#!/bin/sh
set -e

WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME:-wp}"
WORDPRESS_DB_USER="${WORDPRESS_DB_USER:-wpusr}"
WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-wppass}"

# Setup WordPress se non presente
if [ ! -f "/var/www/wp-config.php" ]; then
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz

    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
    sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
    sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" wp-config.php
    sed -i "s/localhost/mariadb/" wp-config.php

    # Puoi aggiungere qui codice per creare l'admin e un utente standard via wp-cli
    # ma per la parte mandatory basta la configurazione DB.

    chown -R nobody:nogroup /var/www || true
fi

exec "$@"
