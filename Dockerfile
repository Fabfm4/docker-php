FROM php:5.6-apache

ENV SITE_DIR /var/www/html
ENV CERTS_DIR /config/certs
ENV LOGS_DIR /config/logs
ENV LOG_FILE_PHP /config/logs/error.log

RUN mkdir -p $CERTS_DIR
RUN mkdir -p $LOGS_DIR
RUN touch $LOG_FILE_PHP
RUN a2enmod rewrite
RUN a2enmod proxy
RUN a2enmod proxy_fcgi

RUN apt-get update && apt-get install -y libmcrypt-dev python-pip libicu-dev libxml2-dev \
    libxslt1-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev git vim openssh-server ocaml expect mysql-client
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install bcmath mcrypt intl json gd pdo_mysql mysql mysqli soap xsl zip

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

COPY ./files/php.ini /usr/local/etc/php

WORKDIR $SITE_DIR

