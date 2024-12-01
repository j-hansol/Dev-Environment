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
    apt install -y php8.3-apcu php8.3-bcmath php8.3-cli php8.3-curl php8.3-dev \
    php8.3-fpm php8.3-gd php8.3-http php8.3-imagick php8.3-imap php8.3-intl \
    php8.3-mailparse php8.3-mbstring php8.3-mcrypt php8.3-memcache php8.3-mongodb \
    php8.3-mysql php8.3-opcache php8.3-pgsql php8.3-readline php8.3-redis \
    php8.3-sqlite3 php8.3-ssh2 php8.3-uuid php8.3-xdebug php8.3-xml php8.3-xmlrpc \
    php8.3-xsl php8.3-yaml php8.3-zip php8.3-raphf

RUN curl https://deb.nodesource.com/setup_lts.x | bash -; \
    apt install -y nodejs

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.3/fpm/php.ini; \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.3/fpm/php.ini; \
    sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.3/fpm/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.3/fpm/php.ini; \
    sed -i 's/user = www-data/user = ubuntu/g' /etc/php/8.3/fpm/pool.d/www.conf; \
    echo "xdebug.mode = develop,debug" >> /etc/php/8.3/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.3/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/8.3/mods-available/xdebug.ini

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