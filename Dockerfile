FROM php:5.6-fpm
MAINTAINER Mateusz Lerczak <mlerczak@pl.sii.eu>

ARG MAGENTO_ROOT="/var/www/html"
ARG PATH_XDEBUG_INI="/usr/local/etc/php/conf.d/xdebug.ini"

ENV TERM xterm

RUN \
    apt-get update \
    && apt-get install -y \
        cron \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxslt1-dev \
        supervisor \
        ssmtp

RUN \
    docker-php-ext-configure \
        gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        bcmath \
        gd \
        intl \
        mbstring \
        mcrypt \
        pdo_mysql \
        soap \
        xsl \
        zip \
        opcache

COPY container /

RUN \
    pecl install lzf xdebug \
    && sed -i "1izend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" ${PATH_XDEBUG_INI}

RUN \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sS https://files.magerun.net/n98-magerun.phar -o /usr/local/bin/magerun \
    && chmod +x /usr/local/bin/magerun

RUN \
    crontab -u www-data /etc/cron.d/magento-crons \
    && mkdir -p /var/log/supervisor

RUN \
    pear install pear/PHP_CodeSniffer

CMD ["/usr/bin/supervisord"]

WORKDIR ${MAGENTO_ROOT}
