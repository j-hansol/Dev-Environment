FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV LC_ALL=C.UTF-8

WORKDIR /DevHome/sites
RUN mkdir -p /DevHome/sites/admin; ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; echo $TZ > /etc/timezone

RUN apt update; \
    apt upgrade -y; \
    apt install -y vim gnupg curl ca-certificates zip unzip git libpng-dev python3 dnsutils librsvg2-bin fswatch ffmpeg nano apache2 mysql-client; \
    apt install -y software-properties-common; \ 
    add-apt-repository -y ppa:ondrej/php; \
    apt update; \
    apt install -y php8.2-bcmath php8.2-cli php8.2-fpm php8.2-curl php8.2-dev php8.2-gd php8.2-intl php8.2-ldap php8.2-mbstring php8.2-mysql php8.2-opcache php8.2-readline \
    php8.2-soap php8.2-xml php8.2-xsl php8.2-zip php8.2-xdebug libapache2-mod-php8.2; \
    a2enmod rewrite vhost_alias ssl; \
    curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer; \
    curl https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get update; \
    apt-get install -y nodejs; \
    npm install -g pnpm; \
    npm install -g bun; \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /etc/apt/keyrings/yarn.gpg >/dev/null; \
    echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list; \
    apt-get update; \
    apt-get install -y yarn; \
    apt-get -y autoremove; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.2/apache2/php.ini; \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.2/apache2/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.2/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.2/apache2/php.ini; \
    echo "xdebug.mode = develop,debug" >> /etc/php/8.2/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.2/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/8.2/mods-available/xdebug.ini

COPY index.php /var/www/html/index.php
COPY svhost.sh /usr/bin/svhost
COPY ssl_key/* /etc/ssl/private
ADD myadmin /var/www/html/myadmin
COPY docker_entrypoint.sh /usr/bin/docker_entrypoint.sh
COPY confs/* /etc/apache2/sites-available

RUN rm -f /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*; \
    chmod 0755 /usr/bin/svhost; \
    chmod 0755 /usr/bin/docker_entrypoint.sh

COPY confs/* /etc/apache2/sites-available

VOLUME [ "/DevHome" ]

EXPOSE 80 443 5173 8080

ENTRYPOINT [ "docker_entrypoint.sh" ]

CMD ["tail","-f","/var/log/apache2/error.log"]