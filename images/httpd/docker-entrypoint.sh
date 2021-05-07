#!/bin/bash
set -e

USER=daemon

if [ -n "$UID" ] && [ -n "$GID" ]; then
	usermod -u $UID $USER
	groupmod -g $GID $USER
fi

if [ -n "$WORK_DIR" ];then
	echo "Define WORK_DIR $WORK_DIR" > /usr/local/apache2/conf/extra/httpd-vhosts-env.conf
fi

exec "$@"