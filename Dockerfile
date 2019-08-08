FROM php:7.2-fpm-buster
MAINTAINER Mateusz Lerczak <mateusz@lerczak.eu>

ARG MAGENTO_USERNAME="magento"
ARG MAGENTO_UID=1000
ARG MAGENTO_ROOT="/srv/magento2.3"
ARG NR_INSTALL_KEY="aaaaabbbbbcccccdddddeeeeefffffggggghhhhh"
ARG NR_INSTALL_SILENT=1
ARG PATH_XDEBUG_INI="/usr/local/etc/php/conf.d/xdebug.ini"
ARG PATH_IMAGICK_INI="/usr/local/etc/php/conf.d/imagick.ini"

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/srv/magento2.3/bin
ENV NEWRELIC_APPNAME="Docker PHP"
ENV PHP_USER ${MAGENTO_USERNAME}
ENV PHP_GROUP ${MAGENTO_USERNAME}
ENV PHP_PORT 9000
ENV PHP_PM dynamic
ENV PHP_PM_MAX_CHILDREN 10
ENV PHP_PM_START_SERVERS 4
ENV PHP_PM_MIN_SPARE_SERVERS 2
ENV PHP_PM_MAX_SPARE_SERVERS 6
ENV TERM xterm


RUN \
    useradd -u ${MAGENTO_UID} -ms /bin/bash ${MAGENTO_USERNAME} \
    && chown -R ${MAGENTO_USERNAME}:${MAGENTO_USERNAME} /srv

RUN apt update \
    && apt-get install -y gnupg2 supervisor msmtp libjpeg-dev libpng-dev libfreetype6-dev libicu-dev libxml2-dev libxslt1-dev imagemagick libmagickwand-dev cron

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt install -y nodejs

# NewRelic agent
RUN \
    curl https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list \
    && apt update \
    && apt install -y newrelic-php5

RUN \
    docker-php-ext-configure \
        gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        bcmath \
        gd \
        intl \
        mbstring \
        hash \
        pdo_mysql \
        soap \
        xsl \
        zip \
        pcntl \
        opcache

COPY container /

RUN \
    pecl install xdebug \
    && sed -i "1izend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" ${PATH_XDEBUG_INI}

RUN \
    pecl install imagick \
    && echo "extension=$(find /usr/local/lib/php/extensions/ -name imagick.so)" > ${PATH_IMAGICK_INI}

RUN \
    newrelic-install install \
    && sed -i "s/PHP Application/\${NEWRELIC_APPNAME}/g" /usr/local/etc/php/conf.d/newrelic.ini \
    && sed -i "s/${NR_INSTALL_KEY}/\${NEWRELIC_KEY}/g" /usr/local/etc/php/conf.d/newrelic.ini

RUN \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sS https://files.magerun.net/n98-magerun2.phar -o /usr/local/bin/magerun2 \
    && chmod +x /usr/local/bin/magerun2

RUN \
    mkdir -p /var/log/supervisor \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
    curl https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -o /usr/local/bin/phpcs \
    && curl https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -o /usr/local/bin/phpcbf \
    && chmod a+x /usr/local/bin/phpcs \
    && chmod a+x /usr/local/bin/phpcbf

CMD ["/usr/bin/supervisord"]

WORKDIR ${MAGENTO_ROOT}
