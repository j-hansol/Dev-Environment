# 개발환경 구성

## 개발 업무

일단 나의 개발 업무를 보면 아래와 같이 3개의 항목으로 나열해 볼 수 있을 것 같다.

* PHP 버전 5.6, 7.x, 8.x 등으로 구성된 사이트 혹은 서비스를 유지보수한다.
* 도매인 호스트이름 기반 동적 사이트 등을 개발하고 유지보수한다.
* Apache Solr를 이용한 검색 기능을 하는 사이트를 유지보수한다.

## 필요한 도커 컨테이너

위 업무를 위해 도커와 몇가지 도구를 이용하여 개발환경을 구성한다.

* PHP 버전별 도커 컨테이너, 데이터베이스 컨테이너, Apache Solr 컨테이너
* 내부 도매인 주소 공유를 위한 도구 (DNsmasq, Acrylic Dns proxy)

### PHP 버전별 도커 컨테이너

PHP 버전별 컨테이느는 아래와 같이 3개로 구성하고 각각에 태그를 붙여 도커허브에 저장한다.

* pig482/devenv:p56 : PHP 5.6용 컨테이너
* pig482/devenv:p74 : PHP 7.4용 컨테이너
* pig482/devenv:p82 : PHP 8.2용 컨테이너

### 데이터베이스 도커 컨테이너

프로젝트 중 시간권 문제에 민감한 것이 있어 기존 MySQL 공식 도커 이미지의 도커 Dockerfile을 수정하여 이용한다.

* pig482/mysql:kr : 시간권을 서울로 지정한 MySQL 데이터베이스

### 검색엔진 도커 컨테이너

중유 유지보수 사이트의 경우 검색인진 기능이 탑제되어 있고, 검색엔진 기능은 Apache Solr를 이용한다. 이에 해당 도커 컨테이너를 생성한다.

* pig482/solr:55 : Apache Solr 5.5.5 도커 컨테이너


## 컨테이너 빌더 리소스 구성

### PHP 5.6 도커 켄테이너
본 저장소의 [dev_env56](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env56)에 관련 파일이 저장되어 있다. 각각의 파일에 대한 간단한 설명은 아래와 같다.

* myadmin : PhpMyAdmin 프로그램 폴더
* ssl_key : 셀스서명한 키파일 폴더
* Dockerfile : 도커 이미지 빌드용 파일
* docker_entrypoint.sh : 컨테이너 실행 시 실행될 스크립트
* drush : Drupal 7.x 사이트 관리 도구
* index.php : 컨테이너에서 관리 중인 사이트 도우미 프로그램
* site.conf : 멀티 호스트 도매인 사이트용 Apache2 환경설정 파일
* sites.conf : 일반적인 사이트를 위한 Apache2 환경설정 파일
* svhost.sh : 멀티 호스트 도매인 사이트, 일반적인 사이트 운영 모드 변경옹 스크립트

위 파일 중 ```drush```를 제외한 너머지 파일은 내용은 조검씩 다를 수 있으나 기능이 같다. 그래서 나머지 컨테이너에서는 잠시 생락한다.

### PHP 7.4 / 8.2 도커 컨테이너

위 파일 중 ```drush```를 제외한 파일이 준비되어 있다. 자세한 파일 구성은 아래 링크를 클릭하여 확인할 수 있다.

* [PHP 7.4](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env74)
* [PHP 8.2](https://github.com/j-hansol/Dev-Environment/tree/master/dev_env82)

### MySQL 도커 컨테이너

MySQL 의 경우 나의 업무 중 시간권과 관련하여 민감한 부분이 있어 부득이하게 시간권을 설정해야 했다. 그래서 기존 MySQL 최신 컨테이너 Dockerfile을 약간 수정하여 사옹한다. 그리고 인증 함수도 변경한다. 자세한 내용은 [Mysql_kr](https://github.com/j-hansol/Dev-Environment/tree/master/mysql_kr)에서 확인할 수 있다.

* config : MySQL 필수 환경설정 파일
* Dockerfile : 도커 이미지 빌드용 파일
* docker_entrypoint.sh : 컨테이너 실행 시 실행될 스크립트

### Solr 도커 컨테이너

이 컨테이너는 검색엔진의 한 종류인 Apache Solr를 위한 컨테이너로 지금도 유지보수 중인 Drupal 7.x와 Apache Solr 5.5.5 연동을 위해 먼들어졌다. 기존 Solr 설정에 한국어 형태소 은전한닢 프로젝트의 형태소 분식기를 적용하고, Drupal의 필드시스템과 연동 가능하도록 각종 필드 타입을 설정한다. 파일 구성은 아래와 같다. 자세한 내용은 [solr](https://github.com/j-hansol/Dev-Environment/tree/master/solr)에서 확인할 수 있다.

* confs/drupal : 드루팔용 설정파일 폴더
* make_files : 형태소 분석기 빌드용 메이퍼파일 폴더
* tars : 형태소 분석기, 사전파일 등의 압축파일 폴더
* Dockerfile : 도커 이미지 빌드용 파일
* docker_entrypoint.sh : 컨테이너 실행 시 실행될 스크립트

## 구성 파일 설명

이미 알고 있는 구성 파일에서는 여기서만 적용되어 있는 내용 위주로 설명하고, 추가된 구성 파일에 대해서는 보다 자세하게 설명하려고 한다.

### PHP Dockerfile

각 버전의 Dockerfile에는 아래와 같이 동적 사이트 설정이 가능하도록 vhost_alias, rewrite, ssl Apache module을 활성화한다.
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
COPY site*.conf /etc/apache2/sites-available
COPY index.php /var/www/html/index.php
COPY svhost.sh /usr/bin/svhost
COPY ssl_key/* /etc/ssl/private
ADD myadmin /var/www/html/myadmin
RUN chmod 0755 /usr/bin/svhost
```

각종 개발 욉사이트가 위치할 공유 폴더를 생성한다. 공유 폴더는 ```/DevHome