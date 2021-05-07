#!/bin/bash
set -e

USER=dev
ENV_PHP="development"
ROOT_PASS=root

function run_command() {
	echo $1
	if ! [ $(id -u) = 0 ]; then
		echo $ROOT_PASS | su -c  "$1"
	else
		$1
	fi
}

run_command "service cron start" || true

if [ -n "$ENV" ] && [ "$ENV" = "production" ]; then
	ENV_PHP=$ENV
fi

run_command "cp -rf $PHP_INI_DIR/php.ini-$ENV_PHP $PHP_INI_DIR/php.ini"

if [ -n "$UID" ] && [ -n "$GID" ]; then
	run_command "usermod -u $UID $USER && groupmod -g $GID $USER"
fi

if [ -n "$XDEBUG_REMOTE_ENABLE" ]; then
	run_command "echo 'zend_extension = xdebug.so' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug-enable.ini"
else
	run_command "rm -rf /usr/local/etc/php/conf.d/docker-php-ext-xdebug-enable.ini"
fi

if [ -n "$DOWNGRADE_OPENSSL_TLS_AND_SECLEVEL" ]; then
	run_command "sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1',g' /etc/ssl/openssl.cnf"
    run_command "sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf"
fi

if [ -n "$USE_SENDMAIL" ]; then
	run_command "ln -sf /etc/alternatives/sendmail /usr/sbin/sendmail"
	run_command "service sendmail start" || true
else
	run_command "ln -sf /usr/bin/msmtp /usr/sbin/sendmail"
	run_command "service sendmail stop" || true
fi

exec docker-php-entrypoint "$@"
