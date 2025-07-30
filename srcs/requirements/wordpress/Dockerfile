FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Installazioni base
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql curl unzip less mariadb-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Scarica WordPress e wp-cli
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# Prepara la directory WordPress
RUN mkdir -p /var/www/html

WORKDIR /var/www/html

# Copia lo script di setup
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["setup.sh"]