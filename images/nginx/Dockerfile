FROM nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /docker-entrypoint.d/docker-entrypoint-custom.sh
COPY snippets /etc/nginx/snippets

RUN chmod +x /docker-entrypoint.d/docker-entrypoint-custom.sh \
	&& mkdir -p /etc/nginx/ssl \
	&& openssl req -x509 -nodes -days 730 \
		-subj  "/C=US/ST=TX/L=Austin/O=Docker/OU=Cloud Docker/CN=local.dev" \
     	-newkey rsa:2048 -keyout /etc/nginx/ssl/self-signed.key \
     	-out /etc/nginx/ssl/self-signed.crt
