FROM alpine:3.20.3

RUN apk update && apk add --no-cache mariadb mariadb-client

# Prepara run directory per mysqld (compatibilità Alpine/MariaDB)
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY conf/setup_db.sh /setup_db.sh
RUN chmod +x /setup_db.sh

VOLUME /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["/setup_db.sh"]
