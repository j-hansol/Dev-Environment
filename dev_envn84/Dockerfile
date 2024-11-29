FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV LC_ALL=C.UTF-8

RUN apt update; \
    apt upgrade -y; \
    apt install -y wget vim debconf-utils curl python3 mysql-client nginx; \
    echo tzdata tzdata/Areas select Asia | debconf-set-selections; \
    echo tzdata tzdata/Zones/Asia select Seoul | debconf-set-selections; \
    apt install -y software-properties-common; \
    echo "Asia/Seoul" > /etc/timezone; \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime; \
    apt install -y git-all

RUN add-apt-repository -y ppa:ondrej/php; \
    apt update; \
    apt install -y php8.4-apcu php8.4-bcmath php8.4-cli php8.4-curl php8.4-dev \
    php8.4-fpm php8.4-gd php8.4-http php8.4-imagick php8.4-imap php8.4-intl \
    php8.4-mailparse php8.4-mbstring php8.4-mcrypt php8.4-memcache php8.4-mongodb \
    php8.4-mysql php8.4-opcache php8.4-pgsql php8.4-readline php8.4-redis \
    php8.4-sqlite3 php8.4-ssh2 php8.4-uuid php8.4-xdebug php8.4-xml php8.4-xmlrpc \
    php8.4-xsl php8.4-yaml php8.4-zip php8.4-raphf

RUN curl https://deb.nodesource.com/setup_lts.x | bash -; \
    apt install -y nodejs

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.4/fpm/php.ini; \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.4/fpm/php.ini; \
    sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.4/fpm/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.4/fpm/php.ini; \
    echo "xdebug.mode = develop,debug" >> /etc/php/8.4/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.4/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/8.4/mods-available/xdebug.ini

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/bin --filename=composer; \
    rm -f composer-setup.php

COPY index.php /var/www/html
COPY ssl_key/* /etc/ssl/private
COPY default /etc/nginx/sites-available
ADD myadmin /var/www/html/myadmin
COPY docker_entrypoint.sh /usr/bin/docker_entrypoint.sh

RUN chmod 0755 /usr/bin/docker_entrypoint.sh; \
    rm -r /var/lib/apt/lists /var/cache/apt/archives

VOLUME [ "/DevHome" ]

EXPOSE 80 443 5173 8080

ENTRYPOINT [ "docker_entrypoint.sh" ]

WORKDIR /DevHome

CMD ["tail","-f","/var/log/nginx/error.log"]