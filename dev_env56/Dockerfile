FROM ubuntu:latest

RUN apt update; \
    apt upgrade -y
    
RUN apt install -y wget vim debconf-utils mysql-client apache2; \
    a2enmod rewrite vhost_alias ssl

RUN echo tzdata tzdata/Areas select Asia | debconf-set-selections; \
    echo tzdata tzdata/Zones/Asia select Seoul | debconf-set-selections; \
    apt install -y software-properties-common; \
    echo "Asia/Seoul" > /etc/timezone; \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN add-apt-repository -y ppa:ondrej/php; \
    apt update; \
    apt -y install php5.6 php5.6-pdo php5.6-gd php5.6-mbstring php5.6-cli \
    php5.6-mysql php5.6-dba php5.6-pdo php5.6-intl php5.6-curl php5.6-simplexml \
    php5.6-xmlrpc php5.6-zip php5.6-dev php5.6-xdebug

RUN update-alternatives --set php /usr/bin/php5.6;

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/5.6/cgi/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/5.6/cgi/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/5.6/cgi/php.ini; \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/5.6/apache2/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/5.6/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/5.6/apache2/php.ini

RUN echo "xdebug.remote_enable=1" >> /etc/php/5.6/mods-available/xdebug.ini; \
    echo "xdebug.remote_host=host.docker.internal" >> /etc/php/5.6/mods-available/xdebug.ini; \
    echo "xdebug.remote_port=9000" >> /etc/php/5.6/mods-available/xdebug.ini

RUN rm -f /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*
COPY confs/* /etc/apache2/sites-available
COPY index.php /var/www/html/index.php
COPY svhost.sh /usr/bin/svhost
COPY ssl_key/* /etc/ssl/private
ADD myadmin /var/www/html/myadmin
RUN chmod 0755 /usr/bin/svhost

COPY docker_entrypoint.sh /usr/bin/docker_entrypoint.sh
RUN chmod 0755 /usr/bin/docker_entrypoint.sh

COPY drush /usr/bin/drush
RUN chmod 0755 /usr/bin/drush

RUN mkdir /DevHome
RUN rm -r /var/lib/apt/lists /var/cache/apt/archives
ENV LC_ALL=C.UTF-8

RUN echo "\nif [ -e \"/etc/apache2/sites-enabled/sites.conf\" ]\nthen\n\tcd /DevHome/sites\nelif [ -e \"/etc/apache2/sites-enabled/domains.conf\" ]\nthen\n\tcd /DevHome/domains\nfi" >> /root/.bashrc

VOLUME [ "/DevHome" ]

EXPOSE 80 443

ENTRYPOINT [ "docker_entrypoint.sh" ]

CMD ["tail","-f","/var/log/apache2/error.log"]