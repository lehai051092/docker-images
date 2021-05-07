#!/bin/sh
set -e

USER=dev
ROOT_PASS=root

# start cron
echo $ROOT_PASS | su -c  "service cron start"

if [ -n "$UID" ] && [ -n "$GID" ]; then
	echo $ROOT_PASS | su -c  "usermod -u $UID $USER && groupmod -g $GID $USER"
fi

if [ -n "$DOWNGRADE_OPENSSL_TLS_AND_SECLEVEL" ]; then
	echo $ROOT_PASS | su -c  "sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1',g' /etc/ssl/openssl.cnf"
    echo $ROOT_PASS | su -c  "sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf"
fi

if [ -n "$USE_SENDMAIL" ]; then
	echo $ROOT_PASS | su -c  "ln -sf /etc/alternatives/sendmail /usr/sbin/sendmail"
	echo $ROOT_PASS | su -c  "service sendmail start"
else
	echo $ROOT_PASS | su -c  "ln -sf /usr/bin/msmtp /usr/sbin/sendmail"
	echo $ROOT_PASS | su -c  "service sendmail stop"
fi

exec "$@"