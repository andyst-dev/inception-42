FROM debian:bookworm

# update les paquets et installe NGINX, OpenSSL pour TLS
RUN apt-get update -y && apt-get upgrade -y && \
	apt-get install -y nginx openssl && \
	rm -rf /var/lib/apt/lists/*

# cree les dossiers utiles pour les certificats SSL
RUN mkdir -p /etc/nginx/ssl /var/www/html

# copie la config NGINX et le script de demarrage
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# expose uniquement le port 443 (HTTPS)
EXPOSE 443

# lance le script de setup
CMD ["/usr/local/bin/setup.sh"]