FROM php:7.1-cli
MAINTAINER Mateusz Lerczak <mlerczak@pl.sii.eu>

ARG USER_NAME="development"
ARG USER_UID=1502
ARG MAGENTO_ROOT="/srv/magento2"

RUN \
    useradd -u ${USER_UID} -ms /bin/bash ${USER_NAME} \
    && chown -R ${USER_NAME}:${USER_NAME} /srv

RUN \
    apt-get update \
    && apt-get install -y \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxslt1-dev \
        ssmtp \
        git

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
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sS https://files.magerun.net/n98-magerun2.phar -o /usr/local/bin/magerun2 \
    && chmod +x /usr/local/bin/magerun2

WORKDIR ${MAGENTO_ROOT}

USER ${USER_NAME}