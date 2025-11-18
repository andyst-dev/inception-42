#!/bin/bash

if [ -f /run/secrets/db_password ]; then
	MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f /run/secrets/wp_admin_password ]; then
	WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi
if [ -f /run/secrets/wp_user_password ]; then
	WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
fi

echo "Attente de la disponibilité de MariaDB..."
until mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
	echo "MariaDB n'est pas encore prêt - attente..."
	sleep 2
done
echo "MariaDB est prêt !"

cd /var/www/html

# si WordPress n'est pas encore instal
if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Téléchargement de WordPress..."
	
	# telecharge WordPress
	wp core download --allow-root
	echo "Configuration de WordPress..."

	# cree le fichier wp-config.php
	wp config create \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost=mariadb \
		--allow-root

	# installe WordPress
	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="Inception" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--allow-root

	# cree un deuxieme utilisateur editor
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--role=editor \
		--user_pass="${WP_USER_PASSWORD}" \
		--allow-root

	echo "WordPress installé avec succès !"

	# change les permissions
	chown -R www-data:www-data /var/www/html
	chmod -R 755 /var/www/html
fi

# creee le dossier pour PHP-FPM
mkdir -p /run/php

# lance PHP-FPM en foreground (PID 1)
echo "Démarrage de PHP-FPM..."
exec php-fpm8.2 -F
