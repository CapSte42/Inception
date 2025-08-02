#!/bin/sh
set -e

# Crea le directory necessarie per i socket
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Assicurati che la directory del database abbia i permessi corretti
chown -R mysql:mysql /var/lib/mysql
chmod -R 755 /var/lib/mysql

# Inizializza il DB se serve
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Prendi le variabili da env (usa default di sicurezza se mancano)
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-toor}"
MYSQL_DATABASE="${MYSQL_DATABASE:-inception}"
MYSQL_USER="${MYSQL_USER:-user}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-password}"

# Imposta root e crea utente/database custom solo se serve
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --bootstrap <<EOF
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

# Avvia MariaDB normalmente (foreground, logging su console)
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --console
