FROM alpine:3.20.3

RUN apk update && apk add --no-cache nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY ssl /etc/nginx/ssl

VOLUME /var/www

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
