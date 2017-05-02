FROM alpine:3.5

MAINTAINER Hex "hex@codeigniter.org.cn"

# install
RUN apk add --no-cache \
    nginx \
    php5-fpm \
    php5-apcu \
    php5-ctype \
    php5-curl \
    php5-dom \
    php5-gd \
    php5-iconv \
    php5-json \
    php5-mcrypt \
    php5-mysql \
    php5-opcache \
    php5-openssl \
    php5-pdo \
    php5-pdo_mysql \
    php5-mysqli \
    php5-xml \
    php5-xsl \
    php5-bcmath \
    php5-zlib \
    s6

# strip
RUN apk add --no-cache --virtual .build-deps binutils \
    && strip /usr/bin/php-fpm \
    && apk del --no-cache .build-deps

# clean
RUN rm /usr/bin/php5 \
    && rm /usr/bin/php \
    && rm /usr/bin/phpize5 \
    && rm /usr/bin/phpize \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && rm -rf /var/www

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx.vh.default.conf /etc/nginx/conf.d/default.conf

COPY conf/php-fpm.conf /etc/php5/php-fpm.conf
COPY conf/php.ini /etc/php5/php.ini

COPY s6/ /etc/s6/

RUN chmod -R +x /etc/s6/* \
    && chmod +x /etc/s6/.s6-svscan/finish \
    && chown -R nginx:nginx /var/lib/nginx/html \
    && chmod -R 775 /var/lib/nginx/html

WORKDIR /var/lib/nginx/html

EXPOSE 80

ENTRYPOINT ["/bin/s6-svscan", "/etc/s6"]
