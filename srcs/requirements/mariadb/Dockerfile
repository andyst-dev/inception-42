FROM debian:bookworm

# instal MariaDB server
RUN apt-get update -y && apt-get upgrade -y && \
	apt-get install -y mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/*

# cree les dossiers utiles
RUN mkdir -p /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld && \
	chmod 777 /var/run/mysqld

# copie le fichier de config
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# copie le script
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# xxpose le port 3306 pour MariaDB
EXPOSE 3306

# lance MariaDB via le script de setup
CMD ["/usr/local/bin/setup.sh"]
