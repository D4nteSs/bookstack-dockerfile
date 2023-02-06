FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN	add-apt-repository ppa:ondrej/php

RUN apt install -y git unzip apache2 php7.4 curl php7.4-fpm php7.4-curl php7.4-mbstring php7.4-ldap \
	php7.4-tidy php7.4-xml php7.4-zip php7.4-gd php7.4-mysql libapache2-mod-php7.4 php7.4-cli \
	php7.4-sqlite3

RUN apt-get install mysql-server mysql-client mysql-server -y

COPY /mysql /var/lib/mysql
COPY /bookstack /var/www
COPY bookstack.conf /etc/apache2/sites-available/

RUN usermod -d /var/lib/mysql/ mysql 
RUN etc/init.d/mysql start &&\
	mysql -u root --execute="CREATE DATABASE bookstack;" && \
	mysql -u root --execute="CREATE USER 'bookstack'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Uveraf05';" &&\
	mysql -u root -pUveraf05 bookstack < /var/lib/mysql/mdump.sql

RUN service mysql start 
RUN chown -R www-data:www-data /var/www/bookstack/ && chmod -R 755 /var/www/bookstack
RUN a2enmod rewrite &&\
	a2enmod php7.4
RUN a2ensite bookstack.conf &&\
	a2dissite 000-default.conf
RUN service apache2 restart

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]

