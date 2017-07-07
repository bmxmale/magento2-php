FROM php:7.0-fpm
MAINTAINER Mateusz Lerczak <mlerczak@pl.sii.eu>

ARG MAGENTO_UID=2000
ARG MAGENTO_ROOT="/srv/magento2"
ARG NR_INSTALL_KEY="aaaaabbbbbcccccdddddeeeeefffffggggghhhhh"
ARG NR_INSTALL_SILENT=1
ARG PATH_XDEBUG_INI="/usr/local/etc/php/conf.d/xdebug.ini.disabled"

ENV NEWRELIC_APPNAME="Docker PHP - Local ENV"
ENV SENDMAIL_HOST="MAILHOG_APP"
ENV SENDMAIL_PORT=1025
ENV PHP_PORT 9000
ENV PHP_PM dynamic
ENV PHP_PM_MAX_CHILDREN 10
ENV PHP_PM_START_SERVERS 4
ENV PHP_PM_MIN_SPARE_SERVERS 2
ENV PHP_PM_MAX_SPARE_SERVERS 6
ENV TERM xterm

COPY container /

RUN \
    useradd -u ${MAGENTO_UID} -ms /bin/bash magento \
    && chown -R magento:magento /srv

RUN \
    curl -sS https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list \
    && apt-get update \
    && apt-get install -y \
        cron \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxslt1-dev \
        supervisor \
        ssmtp \
        newrelic-php5

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

RUN \
    pecl install xdebug \
    && sed -i "1izend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" ${PATH_XDEBUG_INI}

RUN \
    newrelic-install install \
    && sed -i "s/PHP Application/\${NEWRELIC_APPNAME}/g" /usr/local/etc/php/conf.d/newrelic.ini \
    && sed -i "s/${NR_INSTALL_KEY}/\${NEWRELIC_KEY}/g" /usr/local/etc/php/conf.d/newrelic.ini

RUN \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sS https://files.magerun.net/n98-magerun2.phar -o /usr/local/bin/magerun2 \
    && chmod +x /usr/local/bin/magerun2

RUN \
    crontab -u magento /etc/cron.d/magento-crons \
    && mkdir -p /var/log/supervisor

CMD ["/usr/bin/supervisord"]

WORKDIR ${MAGENTO_ROOT}