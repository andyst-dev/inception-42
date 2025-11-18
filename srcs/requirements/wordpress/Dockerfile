FROM debian:bookworm

# installe PHP-FPM et les extensions necessaires pour WordPress
RUN apt-get update -y && apt-get upgrade -y && \
	apt-get install -y \
	php8.2-fpm \
	php8.2-mysql \
	php8.2-curl \
	php8.2-gd \
	php8.2-mbstring \
	php8.2-xml \
	curl \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

# WP-CLI pour les commandes wp dans le script
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# configure PHP-FPM pour le port 9000
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf && \
	sed -i 's|;clear_env = no|clear_env = no|g' /etc/php/8.2/fpm/pool.d/www.conf

# cree le dossier pour WordPress
RUN mkdir -p /var/www/html && \
	chown -R www-data:www-data /var/www/html

# copie le script de setup
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# definit le dossier
WORKDIR /var/www/html

# expose le port 9000 pour PHP-FPM
EXPOSE 9000

# script de setup
CMD ["/usr/local/bin/setup.sh"]
