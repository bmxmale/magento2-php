#!/bin/sh

set -e

if [ -n "${ENABLE_XDEBUG}" ] && [ "${ENABLE_XDEBUG}" == "1" ];
then
    mv /usr/local/etc/php/conf.d/xdebug.ini.disabled /usr/local/etc/php/conf.d/xdebug.ini
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"