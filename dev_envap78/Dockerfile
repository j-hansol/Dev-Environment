FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV LC_ALL=C.UTF-8

RUN apt update; \
    apt upgrade -y

WORKDIR /DevHome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone

RUN apt update; \
    apt upgrade -y; \
    apt install -y gnupg curl ca-certificates zip unzip git libpng-dev python3 dnsutils librsvg2-bin fswatch ffmpeg nano apache2; \
    apt install -y software-properties-common; \ 
    apt install -y sudo vim mysql-client; \
    echo tzdata tzdata/Areas select Asia | debconf-set-selections; \
    echo tzdata tzdata/Zones/Asia select Seoul | debconf-set-selections; \
    echo "Asia/Seoul" > /etc/timezone; \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime; \
    add-apt-repository -y ppa:ondrej/php; \
    apt update; \
    apt install -y php7.4-amqp php7.4-apcu php7.4-apcu-bc php7.4-ast php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-curl php7.4-dev php7.4-ds php7.4-enchant \
    php7.4-excimer php7.4-gd php7.4-gearman php7.4-geoip php7.4-gmp php7.4-gnupg php7.4-http php7.4-igbinary php7.4-imap php7.4-ldap php7.4-json php7.4-mailparse \
    php7.4-memcache php7.4-mongodb php7.4-mysql php7.4-opcache php7.4-pgsql php7.4-raphf php7.4-rdkafka php7.4-readline php7.4-soap php7.4-solr php7.4-sqlite3 \
    php7.4-uuid php7.4-xml php7.4-xmlrpc php7.4-xml php7.4-xmlrpc php7.4-yaml php7.4-intl php7.4-mbstring php7.4-zip php7.4-redis php7.4-imagick php7.4-xdebug libapache2-mod-php7.4; \
    apt install -y php8.2-amqp php8.2-apcu php8.2-bcmath php8.2-bz2 php8.2-cli php8.2-curl php8.2-dba php8.2-dev php8.2-ds php8.2-enchant php8.2-gd php8.2-gearman \
    php8.2-gnupg php8.2-gmp php8.2-http php8.2-igbinary php8.2-imagick php8.2-imap php8.2-intl php8.2-ldap php8.2-mailparse php8.2-mbstring php8.2-mcrypt \
    php8.2-mysql php8.2-memcache php8.2-mongodb php8.2-opcache php8.2-pgsql php8.2-readline php8.2-raphf php8.2-rdkafka php8.2-readline php8.2-redis \
    php8.2-soap php8.2-solr php8.2-sqlite3 php8.2-uuid php8.2-xml php8.2-xmlrpc php8.2-xsl php8.2-zip php8.2-xdebug php8.2-yaml libapache2-mod-php8.2; \
    apt install -y php8.4-amqp php8.4-apcu php8.4-bcmath php8.4-bz2 php8.4-cli php8.4-curl php8.4-dba php8.4-dev php8.4-ds php8.4-enchant php8.4-gd php8.4-gearman \
    php8.4-gmp php8.4-gnupg php8.4-http php8.4-igbinary php8.4-imagick php8.4-imap php8.4-intl php8.4-ldap php8.4-mailparse php8.4-mbstring php8.4-mcrypt php8.4-mcrypt php8.4-memcache \
    php8.4-mongodb php8.4-mysql php8.4-opcache php8.4-pgsql php8.4-raphf php8.4-rdkafka php8.4-readline php8.4-redis php8.4-soap php8.4-sqlite3 php8.4-uuid php8.4-xdebug php8.4-xml \
    php8.4-xmlrpc php8.4-xsl php8.4-yaml php8.4-zip libapache2-mod-php8.4; \
    a2enmod rewrite vhost_alias ssl; \
    curl https://deb.nodesource.com/setup_lts.x | bash -; \
    apt install -y nodejs; \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/bin --filename=composer; \
    rm -f composer-setup.php

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.4/apache2/php.ini; \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/apache2/php.ini; \
    sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/7.4/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.4/apache2/php.ini; \
    echo "xdebug.mode = develop,debug" >> /etc/php/7.4/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/7.4/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/7.4/mods-available/xdebug.ini; \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.2/apache2/php.ini; \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.2/apache2/php.ini; \
    sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.2/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.2/apache2/php.ini; \
    echo "xdebug.mode = develop,debug" >> /etc/php/8.2/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.2/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/8.2/mods-available/xdebug.ini; \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.4/apache2/php.ini; \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.4/apache2/php.ini; \
    sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.4/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.4/apache2/php.ini; \
    echo "xdebug.mode = develop,debug" >> /etc/php/8.4/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.4/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/8.4/mods-available/xdebug.ini

RUN rm -f /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*; \
    rm -f /etc/apache2/mods-enabled/php*
    
COPY index.php /var/www/html/index.php
COPY svhost.sh /usr/bin/svhost
COPY sphp.sh /usr/bin/sphp
COPY ssl_key/* /etc/ssl/private
ADD phpMyAdmin /var/www/html/myadmin
RUN mkdir -p /var/www/html/myadmin/tmp; \
    chown www-data:www-data /var/www/html/myadmin/tmp; \
    echo "ubuntu ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu
COPY docker_entrypoint.sh /usr/bin/docker_entrypoint.sh
COPY confs/* /etc/apache2/sites-available

RUN chmod 0755 /usr/bin/svhost; \
    chmod 0755 /usr/bin/sphp; \
    chmod 0755 /usr/bin/docker_entrypoint.sh

VOLUME [ "/DevHome" ]

EXPOSE 80 443 5173 8080

ENTRYPOINT [ "docker_entrypoint.sh" ]

CMD ["tail","-f","/var/log/apache2/error.log"]