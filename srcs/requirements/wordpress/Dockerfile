FROM alpine:3.20.3

RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-cli \
    php82-mysqli \
    php82-session \
    php82-json \
    php82-curl \
    php82-xml \
    php82-gd \
    mariadb-client \
    curl \
 && ln -s /usr/bin/php82 /usr/bin/php

RUN sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php82/php-fpm.d/www.conf

RUN mkdir -p /var/www
WORKDIR /var/www

COPY conf/setup-wp.sh /setup-wp.sh
RUN chmod +x /setup-wp.sh

VOLUME /var/www

EXPOSE 9000

ENTRYPOINT ["/setup-wp.sh"]
CMD ["php-fpm82", "-F"]
