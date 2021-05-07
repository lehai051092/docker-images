#!/bin/bash
set -e

USER=nginx

if [ -n "$UID" ] && [ -n "$GID" ]; then
	usermod -u $UID $USER
	groupmod -g $GID $USER
fi

if [ -n "$WORKER_PROCESSES" ];then
	sed -i "s/worker_processes .*/worker_processes $WORKER_PROCESSES;/" /etc/nginx/nginx.conf
fi

if [ -n "$WORKER_CONNECTIONS" ];then
	sed -i "s/worker_connections .*/worker_connections $WORKER_CONNECTIONS;/" /etc/nginx/nginx.conf
fi

if [ -n "$UPLOAD_MAX_FILESIZE" ];then
	sed -i "s/client_max_body_size .*/client_max_body_size $UPLOAD_MAX_FILESIZE;/" /etc/nginx/nginx.conf
fi

exit 0
