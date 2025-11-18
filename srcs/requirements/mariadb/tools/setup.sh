#!/bin/bash

if [ -f /run/secrets/db_root_password ]; then
	MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi

if [ -f /run/secrets/db_password ]; then
	MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

# verif que le dossier de donnees appartient à l'utilisateur mysql
mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# si la base de donnees n'est pas init
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "Initialisation de MariaDB..."

	# init la base de donnees si le dossier mysql n'existe pas
	if [ ! -d "/var/lib/mysql/mysql" ]; then
		mysql_install_db --user=mysql --datadir=/var/lib/mysql
	fi

	# demarre MariaDB pour la configuration
	mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
	MYSQL_PID=$!

	echo "Attente du demarrage de MariaDB..."
	for i in {1..30}; do
		if mysqladmin ping --silent; then
			echo "MariaDB est pret !"
			break
		fi
		sleep 1
	done

	# configure MariaDB
	echo "Configuration de MariaDB..."
	mysql -u root << EOF
-- Definit le mot de passe root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Cree la base de donnees WordPress
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Cree l'utilisateur WordPress
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Donne tous les privileges sur la base WordPress
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Supprime les utilisateurs anonymes
DELETE FROM mysql.user WHERE User='';

-- Supprime la base de test
DROP DATABASE IF EXISTS test;

-- Applique les changements
FLUSH PRIVILEGES;
EOF
	
	echo "Configuration terminee."

	mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
	wait $MYSQL_PID
fi

# lance MariaDB en foreground (PID 1)
echo "Demarrage de MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
