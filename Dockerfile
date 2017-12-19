FROM php:7.1-cli
MAINTAINER Mateusz Lerczak <mlerczak@pl.sii.eu>

ARG MAGENTO_UID=2000
ARG MAGENTO_ROOT="/srv/magento2"

RUN \
    useradd -u ${MAGENTO_UID} -ms /bin/bash magento \
    && chown -R magento:magento /srv

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
        ssmtp \        
        xvfb \
        wkhtmltopdf

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
    mkdir -p /var/log/supervisor

RUN \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sS https://files.magerun.net/n98-magerun2.phar -o /usr/local/bin/magerun2 \
    && chmod +x /usr/local/bin/magerun2

CMD ["/usr/bin/supervisord"]

WORKDIR ${MAGENTO_ROOT}
