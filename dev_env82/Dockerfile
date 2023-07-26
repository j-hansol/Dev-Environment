FROM ubuntu:latest

RUN apt update
RUN apt upgrade -y

RUN apt install -y wget vim debconf-utils curl python3

RUN apt install -y mysql-client apache2
RUN a2enmod rewrite vhost_alias ssl
RUN service apache2 restart

RUN echo tzdata tzdata/Areas select Asia | debconf-set-selections
RUN echo tzdata tzdata/Zones/Asia select Seoul | debconf-set-selections
RUN apt install -y software-properties-common
RUN echo "Asia/Seoul" > /etc/timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN apt-get install -y php8.2-bcmath php8.2-bz2 php8.2-cgi php8.2-cli php8.2-common \
	php8.2-curl php8.2-dba php8.2-dev php8.2-enchant php8.2-gd php8.2-gmp php8.2-imap php8.2-intl \
	php8.2-ldap php8.2-mbstring php8.2-mysql php8.2-odbc php8.2-opcache php8.2-phpdbg php8.2-pspell \
	php8.2-readline php8.2-snmp php8.2-soap php8.2-tidy php8.2-xml php8.2-xsl php8.2-zip php8.2-xdebug \
    libapache2-mod-php8.2
RUN curl https://deb.nodesource.com/setup_lts.x | bash -; \
    apt install -y nodejs
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.2/cgi/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.2/cgi/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.2/cgi/php.ini; \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.2/apache2/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.2/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.2/apache2/php.ini

RUN echo "xdebug.mode = develop,debug" >> /etc/php/8.2/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.2/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/8.2/mods-available/xdebug.ini

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