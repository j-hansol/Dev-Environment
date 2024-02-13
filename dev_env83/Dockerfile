FROM ubuntu:latest

RUN apt update
RUN apt install -y whiptail
RUN apt upgrade -y

RUN apt install -y software-properties-common wget vim debconf-utils curl python3 mysql-client apache2
RUN a2enmod rewrite vhost_alias ssl
RUN service apache2 restart

RUN add-apt-repository -y ppa:ondrej/php
RUN apt update

RUN echo tzdata tzdata/Areas select Asia | debconf-set-selections; \
    echo tzdata tzdata/Zones/Asia select Seoul | debconf-set-selections; \
    echo debconf debconf/frontend select Noninteractive | debconf-set-selections
RUN apt install -y php8.3-amqp php8.3-apcu php8.3-ast php8.3-bcmath php8.3-bz2 php8.3-cli \
    php8.3-curl php8.3-dba php8.3-decimal php8.3-dev php8.3-ds php8.3-enchant php8.3-gd \
    php8.3-gearman php8.3-gmp php8.3-gnupg php8.3-grpc php8.3-http php8.3-igbinary \
    php8.3-imagick php8.3-imap php8.3-inotify php8.3-intl php8.3-ldap php8.3-mailparse php8.3-mbstring \
    php8.3-memcache php8.3-msgpack php8.3-mysql php8.3-oauth php8.3-odbc php8.3-opcache php8.3-pcov \
    php8.3-phalcon5 php8.3-phpdbg php8.3-protobuf php8.3-ps php8.3-pspell php8.3-psr php8.3-raphf \
    php8.3-rdkafka php8.3-readline php8.3-redis php8.3-rrd php8.3-smbclient php8.3-snmp php8.3-soap \
    php8.3-solr php8.3-ssh2 php8.3-stomp php8.3-swoole php8.3-tidy php8.3-uopz php8.3-uploadprogress \
    php8.3-uuid php8.3-vips php8.3-xdebug php8.3-xhprof php8.3-xml php8.3-xmlrpc php8.3-xsl \
    php8.3-yaml php8.3-zip php8.3-zmq php8.3-zstd libapache2-mod-php8.3
RUN curl https://deb.nodesource.com/setup_lts.x | bash -; \
    apt install -y nodejs
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.3/cgi/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.3/cgi/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.3/cgi/php.ini; \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.3/apache2/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.3/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.3/apache2/php.ini

RUN echo "xdebug.mode = develop,debug" >> /etc/php/8.3/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.3/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/8.3/mods-available/xdebug.ini

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/bin --filename=composer; \
    rm -f composer-setup.php

RUN rm -f /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*
COPY confs/* /etc/apache2/sites-available
COPY index.php /var/www/html/index.php
COPY svhost.sh /usr/bin/svhost
COPY ssl_key/* /etc/ssl/private
ADD myadmin /var/www/html/myadmin
RUN chmod 0755 /usr/bin/svhost

COPY docker_entrypoint.sh /usr/bin/docker_entrypoint.sh
RUN chmod 0755 /usr/bin/docker_entrypoint.sh
RUN mkdir /DevHome
RUN rm -r /var/lib/apt/lists /var/cache/apt/archives
ENV LC_ALL=C.UTF-8

RUN echo "\nif [ -e \"/etc/apache2/sites-enabled/sites.conf\" ]\nthen\n\tcd /DevHome/sites\nelif [ -e \"/etc/apache2/sites-enabled/domains.conf\" ]\nthen\n\tcd /DevHome/domains\nfi" >> /root/.bashrc

VOLUME [ "/DevHome" ]

EXPOSE 80 443 5173 8080

ENTRYPOINT [ "docker_entrypoint.sh" ]

CMD ["tail","-f","/var/log/apache2/error.log"]