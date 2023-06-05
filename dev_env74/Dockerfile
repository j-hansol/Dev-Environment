FROM ubuntu:latest

RUN apt update
RUN apt upgrade -y

RUN apt install -y wget vim debconf-utils

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
RUN apt-get install -y php7.4 php7.4-cli php7.4-curl php7.4-gd php7.4-json \
    php7.4-mysql php7.4-opcache php7.4-xml php7.4-xml php7.4-xmlrpc \
    php7.4-intl php7.4-ldap php7.4-mbstring php7.4-zip php7.4-redis \
    php7.4-dev php7.4-imagick php7.4-xdebug

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.4/apache2/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/7.4/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.4/apache2/php.ini \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.4/apache2/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/7.4/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.4/apache2/php.ini

RUN echo "xdebug.mode = develop,debug" >> /etc/php/7.4/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/7.4/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/7.4/mods-available/xdebug.ini

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/bin --filename=composer; \
    rm -f composer-setup.php

RUN rm -f /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*
COPY site*.conf /etc/apache2/sites-available
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

RUN echo "\nif [ -e \"/etc/apache2/sites-enabled/sites.conf\" ]\nthen\n\tcd /DevHome/sites\nelif [ -e \"/etc/apache2/sites-enabled/site.conf\" ]\nthen\n\tcd /DevHome/site\nfi" >> /root/.bashrc

VOLUME [ "/DevHome" ]

EXPOSE 80 443

ENTRYPOINT [ "docker_entrypoint.sh" ]

CMD ["tail","-f","/var/log/apache2/error.log"]