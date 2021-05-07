#!/bin/bash
set -e

USER=www-data
ENV_PHP="development"

if [ -n "$ENV" ] && [ "$ENV" = "production" ]; then
	ENV_PHP=$ENV
fi

cp -rf "$PHP_INI_DIR/php.ini-$ENV_PHP" "$PHP_INI_DIR/php.ini"

if [ -n "$UID" ] && [ -n "$GID" ]; then
	usermod -u $UID $USER
	groupmod -g $GID $USER
fi

if [ -n "$FPM_LISTEN_DEFAULT" ]; then
	sed -i 's/^listen = .*/listen = 9000/' /usr/local/etc/php-fpm.d/zz-docker.conf
fi

if [ -n "$XDEBUG_REMOTE_ENABLE" ]; then
	echo "zend_extension = xdebug.so" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug-enable.ini
else
	rm -rf /usr/local/etc/php/conf.d/docker-php-ext-xdebug-enable.ini
fi

if [ -n "$DOWNGRADE_OPENSSL_TLS_AND_SECLEVEL" ]; then
	sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1',g' /etc/ssl/openssl.cnf
    sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf
fi

if [ -n "$USE_SENDMAIL" ]; then
	ln -sf /etc/alternatives/sendmail /usr/sbin/sendmail
	service sendmail start
else
	ln -sf /usr/bin/msmtp /usr/sbin/sendmail
	service sendmail stop
fi

exec docker-php-entrypoint "$@"
