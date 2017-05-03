FROM alpine:3.5

MAINTAINER Hex "hex@codeigniter.org.cn"

# install without iconv
RUN apk add --no-cache \
    nginx \
    php5-fpm \
    php5-apcu \
    php5-bcmath \
    php5-ctype \
    php5-curl \
    php5-dom \
    php5-gd \
    php5-json \
    php5-mcrypt \
    php5-mysql \
    php5-mysqli \
    php5-opcache \
    php5-openssl \
    php5-pdo \
    php5-pdo_mysql \
    php5-xml \
    php5-xmlreader \
    php5-xsl \
    php5-zlib \
    s6 \

    # install php5-iconv

    && apk add --no-cache --virtual .build-deps wget build-base php5-dev autoconf re2c libtool file \

    # Install GNU libiconv

    && rm /usr/bin/iconv \

    && mkdir -p /opt \
    && cd /opt \
    && wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz \
    && tar xzf libiconv-1.15.tar.gz \
    && cd libiconv-1.15 \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \

    # Install PHP iconv from source

    && cd /opt \
    && wget -O php-5.6.30.tar.gz https://secure.php.net/get/php-5.6.30.tar.gz/from/this/mirror \
    && tar xzf php-5.6.30.tar.gz \
    && cd php-5.6.30/ext/iconv \
    && phpize \
    && ./configure --with-iconv=/usr/local \
    && make \
    && make install \
    && echo "extension=iconv.so" >> /etc/php5/conf.d/iconv.ini \

    # strip
    && strip -s /usr/local/lib/libcharset.so.1.0.0 \
       /usr/local/lib/libiconv.so.2.6.0 \
       /usr/local/lib/preloadable_libiconv.so \
       /usr/local/bin/iconv \
       /usr/bin/php-fpm \

    && apk del --no-cache .build-deps \

    # clean
    && rm /usr/bin/php5 \
    && rm /usr/bin/php \
    && rm /usr/bin/phpize5 \
    && rm /usr/bin/phpize \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && rm -rf /opt \
    && rm -rf /usr/local/lib/perl5 \
    && rm -rf /usr/local/lib/libcharset.a \
    && rm -rf /usr/local/include/* \
    && rm -rf /usr/local/share/* \
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

# replace origin iconv
ENV LD_PRELOAD /usr/local/lib/preloadable_libiconv.so

EXPOSE 80

ENTRYPOINT ["/bin/s6-svscan", "/etc/s6"]
