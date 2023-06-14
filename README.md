개발환경 구성
============

개발 업무
--------

개발 업무에서 필요한 요소는 아래와 같다.

* PHP 버전 5.6, 7.x, 8.x 등 3개 버전을 모두 이용한다.
* 단순한 사이트에서부터 도매인 기반 특수 사이트 개발을 해야 한다.
* Apache Solr를 이용한 검색 기능을 하는 사이트 유지보수를 해야한다.

필요한 도커 컨테이너
-------------------

위 업무를 위해 도커와 몇가지 도구를 이용하여 개발환경을 구성한다.

* PHP 버전별 도커 컨테이너, 데이터베이스 컨테이너, Apache Solr 컨테이너
* 내부 도매인 주소 공유를 위한 도구 (DNsmasq, Acrylic Dns proxy)

# PHP 버전별 도커 컨테이너

PHP 버전별 컨테이느는 아래와 같이 3개로 구성하고 각각에 태그를 붙여 도커허브에 저장한다.

* pig482/devenv:p56 : PHP 5.6용 컨테이너
* pig482/devenv:p74 : PHP 7.4용 컨테이너
* pig482/devenv:p82 : PHP 8.2용 컨테이너

# 데이터베이스 도커 컨테이너

프로젝트 중 시간권 문제에 민감한 것이 있어 기존 MySQL 공식 도커 이미지의 도커 Dockerfile을 수정하여 이용한다.

* pig482/mysql:kr : 시간권을 서울로 지정한 MySQL 데이터베이스

# 검색엔진 도커 컨테이너

중유 유지보수 사이트의 경우 검색인진 기능이 탑제되어 있고, 검색엔진 기능은 Apache Solr를 이용한다. 이에 해당 도커 컨테이너를 생성한다.

* pig482/solr:55 : Apache Solr 5.5.5 도커 컨테이너


컨테이너 빌더 리소스 구성
-----------------------

# PHP 도커 칸테이너 빌드 구성 파일

각 버전에 따라 약간 내용이 다를 수 있으나 대부분 아래와 같이 파일을 구성한다.

* myadmin : PhpMyAdmin 프로그램 폴더
* ssl_key : 셀스서명한 키파일 폴더
* Dockerfile : 도커 이미지 빌드용 파일
* docker_entrypoint.sh : 컨테이너 실행 시 실행될 스크립트
* drush : Drupal 7.x 사이트 관리 도구
* index.php : 컨테이너에서 관리 중인 사이트 도우미 프로그램
* confs : Apache site 환경설정 파일
* svhost.sh : 멀티 호스트 도매인 사이트, 일반적인 사이트 운영 모드 변경옹 스크립트

자세한 내용은 각 버전의 소스를 확인한다.

* [PHP 5.6](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env56)
* [PHP 7.4](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env74)
* [PHP 8.2](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env82)

# MySQL 도커 컨테이너 빌드 구성 파일

MySQL 의 경우 나의 업무 중 시간권과 관련하여 민감한 부분이 있어 부득이하게 시간권을 설정해야 했다. 그래서 기존 MySQL 최신 컨테이너 Dockerfile을 약간 수정하여 사옹한다. 그리고 인증 함수도 변경한다. 자세한 내용은 [Mysql_kr](https://github.com/j-hansol/Dev-Environment/tree/master/mysql_kr)에서 확인할 수 있다.

* config : MySQL 필수 환경설정 파일
* Dockerfile : 도커 이미지 빌드용 파일
* docker_entrypoint.sh : 컨테이너 실행 시 실행될 스크립트

# Solr 도커 컨테이너 빌드 구성 파일

이 컨테이너는 검색엔진의 한 종류인 Apache Solr를 위한 컨테이너로 지금도 유지보수 중인 Drupal 7.x와 Apache Solr 5.5.5 연동을 위해 먼들어졌다. 기존 Solr 설정에 한국어 형태소 은전한닢 프로젝트의 형태소 분식기를 적용하고, Drupal의 필드시스템과 연동 가능하도록 각종 필드 타입을 설정한다. 파일 구성은 아래와 같다. 자세한 내용은 [solr](https://github.com/j-hansol/Dev-Environment/tree/master/solr)에서 확인할 수 있다.

* confs/drupal : 드루팔용 설정파일 폴더
* make_files : 형태소 분석기 빌드용 메이커파일 폴더
* tars : 형태소 분석기, 사전파일 등의 압축파일 폴더
* Dockerfile : 도커 이미지 빌드용 파일
* docker_entrypoint.sh : 컨테이너 실행 시 실행될 스크립트

구성 파일 설명
-------------

이미 알고 있는 구성 파일에서는 여기서만 적용되어 있는 내용 위주로 설명하고, 추가된 구성 파일에 대해서는 보다 자세하게 설명하려고 한다.

# PHP Dockerfile

각 버전의 Dockerfile에는 아래와 MySQL 클라이언트와 Apache2, 동적 사이트 설정이 가능하도록 vhost_alias, rewrite, ssl Apache module을 활성화한다.
```
RUN apt install -y mysql-client apache2
RUN a2enmod rewrite vhost_alias ssl
RUN service apache2 restart
```

각 버전별 Dockerfile에는 시간권 설정하는 부분이 추가되어 있다.
```
RUN echo tzdata tzdata/Areas select Asia | debconf-set-selections
RUN echo tzdata tzdata/Zones/Asia select Seoul | debconf-set-selections
RUN apt install -y software-properties-common
RUN echo "Asia/Seoul" > /etc/timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
```

각 버전의 PHP를 설치한다. 아래의 내용은 8.2에 대한 내용으로 다른 버전은 위 레포지터리 링크를 클릭하여 확인한다.
```
RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN apt-get install -y php8.2-bcmath php8.2-bz2 php8.2-cgi php8.2-cli php8.2-common \
	php8.2-curl php8.2-dba php8.2-dev php8.2-enchant php8.2-gd php8.2-gmp php8.2-imap php8.2-intl \
	php8.2-ldap php8.2-mbstring php8.2-mysql php8.2-odbc php8.2-opcache php8.2-phpdbg php8.2-pspell \
	php8.2-readline php8.2-snmp php8.2-soap php8.2-tidy php8.2-xml php8.2-xsl php8.2-zip php8.2-xdebug \
    libapache2-mod-php8.2
```

각 버전 경로의 php.ini를 변경하여 최대 업로드 파일 사이즈, 포스트 최대 사이즈 등을 250MB로 설정한다.
```
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.2/cgi/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/X.X/cgi/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/X.X/cgi/php.ini; \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/X.X/apache2/php.ini; \
	sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/X.X/apache2/php.ini; \
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/X.X/apache2/php.ini
```

각 버전의 xdebug.ini 역시 수정하여 설정한다.
```
RUN echo "xdebug.mode = develop,debug" >> /etc/php/X.X/mods-available/xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /etc/php/X.X/mods-available/xdebug.ini; \
    echo "xdebug.client_port = 9000" >> /etc/php/X.X/mods-available/xdebug.ini
```
```
RUN echo "xdebug.remote_enable=1" >> /etc/php/5.6/mods-available/xdebug.ini; \
    echo "xdebug.remote_host=host.docker.internal" >> /etc/php/5.6/mods-available/xdebug.ini; \
    echo "xdebug.remote_port=9000" >> /etc/php/5.6/mods-available/xdebug.ini
```

composer는 7.4와 8.2에만 설치한다.
```
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/bin --filename=composer; \
    rm -f composer-setup.php
```

그 외 컨테이너 실행 시 필요한 Apache 환경설정 파일 사이트 관리 도우미, 자체 서명한 ssl 키, 데이터베이스 관리용 도구 등을 각각의 폴더에 복사한다.
```
RUN rm -f /etc/apache2/sites-available/* /etc/apache2/sites-enabled/*
COPY confs/* /etc/apache2/sites-available
COPY index.php /var/www/html/index.php
COPY svhost.sh /usr/bin/svhost
COPY ssl_key/* /etc/ssl/private
ADD myadmin /var/www/html/myadmin
RUN chmod 0755 /usr/bin/svhost
```

각종 개발 욉사이트가 위치할 공유 폴더를 생성한다. 공유 폴더는 ```/DevHome```생성한다.
```
RUN mkdir /DevHome
```

각 버전별 도커 컨테이너는 ```sites```, ```domains``` 등 두 개의 모드로 운영된다. 이 모드에 따라 각 프로젝트 폴더에 쉽게 접근 가능하도록 아래외 같은 스크립트를 ```.bashrc``` 파일에 첨가한다.
```
RUN echo "\nif [ -e \"/etc/apache2/sites-enabled/sites.conf\" ]\nthen\n\tcd /DevHome/sites\nelif [ -e \"/etc/apache2/sites-enabled/domains.conf\" ]\nthen\n\tcd /DevHome/domains\nfi" >> /root/.bashrc
```
위 코드는 아래와 같이 추가된다.
```
if [ -e "/etc/apache2/sites-enabled/sites.conf" ]
then
	cd /DevHome/sites
elif [ -e "/etc/apache2/sites-enabled/domains.conf" ]
then
	cd /DevHome/domains
fi
```

# docker_entrypoint.sh
도커 컨테이너가 실행 될 때 아래와 같이 Apache 서비스를 실행한다. ```svhost init``` 은 초기화의 의미로 최초 실행하는 것을 말한다.
```
#!/bin/bash

/usr/bin/svhost init
exec "$@"
```

# svhost.sh
파일은 ```/usr/bin/svhost``` 파일로 복사되어 기본 명령어로 사용된다. 이 스크립트 파일은 Apache 서비스를 실행하고 제어하는 일을 한다.
파일 내용은 아래와 같다.
```
#!/bin/bash

# 파일 체크
function check_available_conf()
{
    file="/etc/apache2/sites-available/$1"
    if [ -e $file ]; then
        echo 1
    else
        echo 0;
    fi
}

# 파일 삭제
function unlink()
{
    file="/etc/apache2/sites-enabled/$1"
    if [ -e $file ]; then
        rm -f "$file"
    fi
}

# 도메인 기반 사이트 환경설정 활성화
function domain_link()
{
    unlink "domains.conf"
    file="/etc/apache2/sites-available/$1"
    if [ -e $file ]; then
        ln -s $file "/etc/apache2/sites-enabled/domains.conf"
        echo 1
    else
        echo 0;
    fi
}

# 개별 사이트 환경설정 활성화
function sites_link()
{
    unlink "sites.conf"
    file="/etc/apache2/sites-available/sites.conf"
    if [ -e $file ]; then
        ln -s $file "/etc/apache2/sites-enabled/sites.conf"
        echo 1
    else
        echo 0
    fi
}

case $1 in
    init)
        if [ $(sites_link) -eq 1 ]; then
            service apache2 start
        else
            echo "Initialization failed"
        fi
        ;;
    sites)
        chk=$(check_available_conf "sites.conf")
        if [ 1 == $chk ]; then
            unlink "domains.conf"
            if [ $(sites_link) -eq 1 ]; then
                service apache2 reload
            else
                echo "Cannot switch modes."
            fi
        else
            echo "Cannot switch modes."
        fi
        ;;
    domains)
        if [ -n $2 ]; then
            chk=$(check_available_conf "domains.$2.conf")
            if [ 1 -eq $chk ]; then
                unlink "sites.conf"
                ret=$(domain_link "domains.$2.conf")
                if [ 1 -eq $ret ]; then
                    service apache2 reload
                else
                    echo "Cannot switch modes."
                fi
            else
                echo "Cannot switch modes."
            fi
        else
            echo "Type document root."
        fi
        ;;
    start)
        service apache2 start
        ;;
    stop)
        service apache2 stop
        ;;
    *)
        echo "Usage : svhost <sites|domains> [document_root]"
        ;;
esac

echo "Done..."
```

# confs 
confs 폴더에는 Apache 서비스를 통해 서비스될 사이트 설정 정보가 저장된 두 파일을 가지고 있다. 이 설정 파일은 vhost_alias 모듈을 이용하여 ```VirtualDocumentRoot``` 를 이용하여 동적인 Document Root를 지정한다.

* domains.conf : 도매인 단위의 사이트 설정파일
* sites.conf : 개별 사이트 설정 파일

# ssl_key
자체 서명한 키 파일을 가지고 있다. 이 파일은 위의 ```domain.conf```, ```sites.conf``` 설정 파일에서 이용한다.

### myadmin
PHPMyAdmin을 도커 환경에 맞게 데이터베이스 계정 정보 및 연결 호스트명을 적용한 파일들이 보관되어 있다.

Apache site configration
-------------------------

# domains.conf
이 설정 파일은 도메인 단위의 사이트를 구성할 목적으로 생성된 것으로 아래와 같은 폴더 구조를 가진다.
단 아래 폴더에는 DocumentRoot 펄더로 ```dev_doc_root``` 폴더나 심블릭 링크가 존재해야 한다.
```
domains
+- abc : abc 프로젝트 폴더 아래의 경우 모두 이 폴더로 연결됨
|        - www.abc.wd
|        - public.abc.wd
|        - store.abc.wd
|
+- public : public 프로젝트 폴더
            - www.public.wd
            - store.public.wd
            - shop.public.wd
```

설정 파일은 아래와 같다. 아래의 내용은 다큐먼트 루터가 public인 경우이다. ```svhost``` 를 이용하면 아래의 public 부분을 변경하여 ```sites-enabled``` 폴더에 ```domains.conf```로 심블릭 링크를 지정한다.
```
<VirtualHost *:80>
    ServerName localhost
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    ServerName domains.wd
    ServerAlias *.*.wd

    ServerAdmin webmaster@localhost
    VirtualDocumentRoot /DevHome/domains/%2/public

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /DevHome/domains/*/public>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:443>
    ServerName domains.wd
    ServerAlias *.*.wd

    ServerAdmin webmaster@localhost
    VirtualDocumentRoot /DevHome/domains/%2/public

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /DevHome/domains/*/public>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateKeyFile /etc/ssl/private/dev.key
    SSLCertificateFile /etc/ssl/private/dev.crt
</VirtualHost>
```

# sites.conf
이 설정 파일은 개별 사이트를 위한 설정이다. 이 설정은 ```다큐먼트루터폴더.프로젝트 폴더.wd``` 형태로 연결되도록 한다.
이 설정은 DocumentRoot 폴더를 고정하지는 않는다. 위의 도매인 주소 입력 규칙에 따라 DocumentRoot 펄더가 지정되는 방식이다.
```
sites
+- shop
|  +- www : www.shop.wd 로 접속 가능하다.
|
+- cafe
   +- store : store.cafe.wd 로 접속 가능하다.
```

설정 파일 내용은 아래와 같다.
```
<VirtualHost *:80>
    ServerName admin.sites.wd
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    ServerName sites.wd
    ServerAlias *.*.wd
    UseCanonicalName Off

    ServerAdmin webmaster@localhost
    VirtualDocumentRoot /DevHome/sites/%2/%1

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /DevHome/sites/*/*>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:443>
    ServerName sites.wd
    ServerAlias *.*.wd
    UseCanonicalName Off

    ServerAdmin webmaster@localhost
    VirtualDocumentRoot /DevHome/sites/%2/%1

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /DevHome/sites/*/*>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateKeyFile /etc/ssl/private/dev.key
    SSLCertificateFile /etc/ssl/private/dev.crt
</VirtualHost>
```

Volume 구성
-----------

# PHP
DevHome : 웹사이트 기본 디렉토리
```
DevHome
+- sites
|  +- project1
|  +- project2
+- domains
   +- project1
   +- project2
```

# MySQL
/var/lib/mysql : 데이터 저장소 디렉토리

# Apache Solr
/opt/solr/server/solr/cores : 검색엔진 코어 저장소 디렉토리
```
/opt/solr/server/solr/cores
+- drupal
   +- conf
   +- data
   +- core.properties
```

Port 노출
---------

# PHP
80(Http), 443(Https)

# MySQL
3306 (기본 포트)

# Solr
8983(전용)

주요 명령
---------

아래 명령은 ```docker-compose.yml``` 을 이용하여 개발환경을 실행하는 것을 기본으로 한다.

# 사이트 모드 변경
개별 사이트 개발 모드
```
docker-compose exec web svhost sites
```

도매인 사이트 개발 모드
```
docker-compose exec web svhost domains docroot
docker-compose exec web svhost domains html
docker-compose exec web svhost domains public
docker-compose exec web svhost domains public_html
docker-compose exec web svhost domains web
docker-compose exec web svhost domains webroot
docker-compose exec web svhost domains www
docker-compose exec web svhost domains wwwroot
```

서버 명령 모드 (라라벨 및 기타 프레임워크의 경우 필요) 이 경우 모드에 따라 sites, domains 폴더까지 이동한다. 프로젝트 폴더로 한 번 더 이동이 필요하다.
```
docker-compose exec web bash
```

개발 도매인 설정
---------------

나의 경우 로컬 개발환경에 다양한 사이트를 윺지보수하고, 새로운 프로젝트를 진행해야 한다. 그것도 짧은 시간에 전환하여 작업을 진행해야 한다. PHP의 버전이 다른 경우에는 어쩔 수 없이 도커 컨테이너를 재실행햐야 하지만 같은 버전이라면 단순히 프로젝트 소스를 불러 오는 작업으로 전환이 가능해야 한다. 이를 위해 위의 모드 변경 기능과 함께 로컬 개발환경용 도매인 설정이나 이용이 용이해야 한다. 여기에 유용한 도구가 두 가지가 있는데, 아래의 Dnsmasq, Arcylic DNS Proxy 이다. 앞의 것은 Mac용이고 후자는 Windows 용이다.

# Dnsmasq 설치

설치 순서는 아래와 같다.
1. Xcode 설치
2. Homebrew 설치
3. Dnsmasq 설치
4. Dnsmasq 설정
5. 버그 수정
6. 데몬 실행

## Xcode 설치
```
xcode-select --install
```

## Homebrew 설치
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Dnsmasq 설치
```
brew install dnsmasq
```

## Dnsmasq 설정
```
cd $(brew --prefix); mkdir etc; echo 'address=/.wd/127.0.0.1' > etc/dnsmasq.conf
sudo mkdir /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/wd'

sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons
```

## 버그 수정
```
sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons
```

그리고 아래 내용을 삭제한다. (이 옵션으로 오류가 발생하고, 데몬이 정상 실행되지 않는다.)
```
<string>-7</string>
<string>/usr/local/etc/dnsmasq.d,*.conf</string>
```

## 데몬 실행
```
sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
```

# Arcylic DNS Proxy
