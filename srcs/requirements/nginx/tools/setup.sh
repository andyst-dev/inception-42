#!/bin/bash

# genere un certificat SSL auto-signed si il existe pas
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/nginx.key \
		-out /etc/nginx/ssl/nginx.crt \
		-subj "/C=FR/ST=France/L=Paris/O=42/CN=${DOMAIN_NAME}" 2>/dev/null
fi

# lance NGINX en foreground (PID 1)
exec nginx -g "daemon off;"
