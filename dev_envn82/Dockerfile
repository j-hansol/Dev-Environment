FROM ubuntu:24.04
ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Seoul
ENV LC_ALL C.UTF-8

WORKDIR /DevHome

RUN mkdir -p /DevHome/sites/admin; ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; echo $TZ > /etc/timezone

RUN apt-get update; \
	apt-get -y upgrade; \
    mkdir -p /etc/apt/keyrings; \
    apt-get install -y gnupg curl ca-certificates zip unzip git libpng-dev python3 dnsutils librsvg2-bin fswatch ffmpeg nano nginx mysql-client; \
    curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null; \
    echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main" > /etc/apt/sources.list.d/ppa_ondrej_php.list; \
    apt-get update; \
    apt-get install -y php8.2-bcmath php8.2-cli php8.2-fpm php8.2-curl php8.2-dev php8.2-gd php8.2-intl php8.2-ldap php8.2-mbstring php8.2-mysql php8.2-opcache php8.2-readline \
    php8.2-soap php8.2-xml php8.2-xsl php8.2-zip php8.2-xdebug; \
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

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.2/fpm/php.ini; \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.2/fpm/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.2/fpm/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.2/fpm/php.ini; \
    echo "xdebug.mode = develop,debug" >> /etc/php/8.2/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.2/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/8.2/mods-available/xdebug.ini

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

CMD ["tail","-f","/var/log/nginx/error.log"]
