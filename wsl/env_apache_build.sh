#!/bin/bash

USERNAME=`whoami`
echo "$USERNAME"
HOMEDIR=`getent passwd $USERNAME | cut -d: -f6`
if [ -z "$HOMEDIR" ]; then
  echo "존재하지 않는 계정입니다."
  exit 1
fi

if [ ! -d "$HOMEDIR" ]; then
  echo "홈 디렉토리가 존재하지 않습니다."
  exit 1
fi

# 운영체제 패키지 저장소 갱신 및 패키지 업그레이드
echo "시스템 패키지 업그레이드"
sudo apt-get update 1> /dev/null
sudo apt-get -y upgrade 1> /dev/null

# 기본 패키지 설치
echo "기본 패키지 설치"
sudo apt-get install -y zip unzip libpng-dev bind9-dnsutils apache2 librsvg2-bin fswatch openssl 1> /dev/null

# PHP 패키지 저장소 추가
echo "PHP 패키지 저장소 추가"
sudo add-apt-repository -y ppa:ondrej/php 1> /dev/null
sudo apt-get update 1> /dev/null

# Oracle 데이터베이스 연결용 라이브러리 설치
echo "Oracle Instant Client 라이브러리 설치"
# 네트워크(DNS) 일시 오류에 대비해 재시도하며 다운로드
# 사용법: download_file <URL> <저장경로> [sudo]
download_file() {
  local url="$1" out="$2" prefix="$3" i
  for i in 1 2 3 4 5; do
    if $prefix wget -q -O "$out" "$url" && [ -s "$out" ]; then
      return 0
    fi
    echo "  다운로드 실패($i/5), 5초 후 재시도: $url"
    $prefix rm -f "$out"
    sleep 5
  done
  echo "  다운로드 최종 실패: $url"
  return 1
}

IC_BASE_URL=https://download.oracle.com/otn_software/linux/instantclient/2119000
sudo mkdir -p /usr/lib/oracle
cd /usr/lib/oracle || exit 1
for pkg in basic sdk; do
  zip=instantclient-$pkg-linux.x64-21.19.0.0.0dbru.zip
  if download_file "$IC_BASE_URL/$zip" "$zip" sudo; then
    sudo unzip -oq "$zip"
  fi
  sudo rm -f "$zip"
done
export ORACLE_HOME=/usr/lib/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME/instantclient_21_19
export PATH=$PATH:$ORACLE_HOME
sudo echo "$LD_LIBRARY_PATH" | sudo tee /etc/ld.so.conf.d/oracle-instantclient.conf
sudo ldconfig

# PHP 7.4 설치
echo "PHP 7.4 설치"
sudo apt-get install -y --fix-missing php7.4-amqp php7.4-apcu php7.4-apcu-bc php7.4-ast php7.4-bcmath php7.4-bz2 php7.4-cli \
    php7.4-curl php7.4-dev php7.4-ds php7.4-enchant php7.4-excimer php7.4-gd php7.4-gearman php7.4-geoip php7.4-gmp \
    php7.4-gnupg php7.4-igbinary php7.4-imap php7.4-ldap php7.4-json php7.4-mailparse php7.4-memcache \
    php7.4-mongodb php7.4-mysql php7.4-opcache php7.4-pgsql php7.4-raphf php7.4-rdkafka php7.4-readline php7.4-soap \
    php7.4-solr php7.4-sqlite3 php7.4-uuid php7.4-xml php7.4-xmlrpc php7.4-xml php7.4-xmlrpc php7.4-yaml php7.4-intl \
    php7.4-mbstring php7.4-zip php7.4-redis php7.4-imagick php7.4-xdebug libapache2-mod-php7.4 1> /dev/null

# oci8 소스 다운르도
echo "Oci8 확장 소스 다운로드"
sudo apt-get -y install glibc-source php-pear build-essential libaio1t64 1> /dev/null
sudo ln -sf /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/libaio.so.1
rm -rf $HOMEDIR/oci8
mkdir -p $HOMEDIR/oci8
cd $HOMEDIR/oci8 || exit 1
# pecl download 대신 PECL 서버에서 직접 받아 재시도 가능하게 함
for ver in 2.2.0 3.2.1 3.4.1; do
  if download_file "https://pecl.php.net/get/oci8-$ver.tgz" "oci8-$ver.tgz"; then
    tar xzf "oci8-$ver.tgz"
  fi
  rm -f "oci8-$ver.tgz"
done

# Oci8 빌드 및 설치
# 사용법: build_oci8 <PHP 버전> <oci8 소스 버전>
build_oci8() {
  local php_ver="$1" src="$HOMEDIR/oci8/oci8-$2" log="$HOMEDIR/oci8/oci8-$1-build.log"
  if [ ! -f "$LD_LIBRARY_PATH/sdk/include/oci.h" ]; then
    echo "  Instant Client SDK가 없어 PHP $php_ver용 Oci8 빌드를 건너뜁니다."
    return 1
  fi
  if [ ! -d "$src" ]; then
    echo "  $src 소스가 없어 PHP $php_ver용 Oci8 빌드를 건너뜁니다."
    return 1
  fi
  cd "$src" || return 1
  [ -f Makefile ] && make distclean > /dev/null 2>&1
  phpize$php_ver > "$log" 2>&1 \
    && ./configure --with-php-config=/usr/bin/php-config$php_ver \
         --with-oci8=instantclient,$LD_LIBRARY_PATH >> "$log" 2>&1 \
    && make >> "$log" 2>&1 \
    && sudo make install >> "$log" 2>&1
  if [ $? -ne 0 ]; then
    echo "  PHP $php_ver용 Oci8 빌드 실패 (로그: $log)"
    cp "$log" "$HOMEDIR/" 2>/dev/null
    return 1
  fi
  echo "extension=oci8.so" | sudo tee /etc/php/$php_ver/mods-available/oci8.ini > /dev/null
  sudo phpenmod -v $php_ver oci8 1> /dev/null
}

# PHP 7.4용 Oci8 빌드 및 설치
echo "PHP 7.4 Oci8 확장 빌드 및 설치"
build_oci8 7.4 2.2.0

# PHP 8.1 설치
echo "PHP 8.1 설치"
sudo apt-get install -y --fix-missing php8.1-amqp php8.1-apcu php8.1-bcmath php8.1-bz2 php8.1-cli php8.1-curl php8.1-dba \
    php8.1-dev php8.1-ds php8.1-enchant php8.1-gd php8.1-gearman php8.1-gnupg php8.1-gmp php8.1-http \
    php8.1-igbinary php8.1-imagick php8.1-imap php8.1-intl php8.1-ldap php8.1-mailparse php8.1-mbstring php8.1-mcrypt \
    php8.1-mysql php8.1-memcache php8.1-mongodb php8.1-opcache php8.1-pgsql php8.1-readline php8.1-raphf \
    php8.1-rdkafka php8.1-readline php8.1-redis php8.1-soap php8.1-solr php8.1-sqlite3 php8.1-uuid php8.1-xml \
    php8.1-xmlrpc php8.1-xsl php8.1-zip php8.1-xdebug php8.1-yaml libapache2-mod-php8.1 1> /dev/null

# PHP 8.1용 oci8 빌드 및 설치
echo "PHP 8.1용 Oci8 빌드 및 설치"
build_oci8 8.1 3.2.1

# PHP 8.2 설치
echo "PHP 8.2 설치"
sudo apt-get install -y --fix-missing php8.2-amqp php8.2-apcu php8.2-bcmath php8.2-bz2 php8.2-cli php8.2-curl php8.2-dba \
    php8.2-dev php8.2-ds php8.2-enchant php8.2-gd php8.2-gearman php8.2-gnupg php8.2-gmp php8.2-http php8.2-igbinary \
    php8.2-imagick php8.2-imap php8.2-intl php8.2-ldap php8.2-mailparse php8.2-mbstring php8.2-mcrypt php8.2-mysql \
    php8.2-memcache php8.2-mongodb php8.2-opcache php8.2-pgsql php8.2-readline php8.2-raphf php8.2-rdkafka \
    php8.2-readline php8.2-redis php8.2-soap php8.2-solr php8.2-sqlite3 php8.2-uuid php8.2-xml php8.2-xmlrpc \
    php8.2-xsl php8.2-zip php8.2-xdebug php8.2-yaml libapache2-mod-php8.2 1> /dev/null

# PHP 8.2 oci8 빌드 및 설치
echo "PHP 8.2용 Oci8 빌드 및 설치"
build_oci8 8.2 3.4.1

# PHP 8.4 설치
echo "PHP 8.4 설치"
sudo apt-get install -y --fix-missing php8.4-amqp php8.4-apcu php8.4-bcmath php8.4-bz2 php8.4-cli php8.4-curl php8.4-dba \
    php8.4-dev php8.4-ds php8.4-enchant php8.4-gd php8.4-gearman php8.4-gmp php8.4-gnupg php8.4-http php8.4-igbinary \
    php8.4-imagick php8.4-imap php8.4-intl php8.4-ldap php8.4-mailparse php8.4-mbstring php8.4-mcrypt php8.4-mcrypt \
    php8.4-memcache php8.4-mongodb php8.4-mysql php8.4-opcache php8.4-pgsql php8.4-raphf php8.4-rdkafka php8.4-readline \
    php8.4-redis php8.4-soap php8.4-sqlite3 php8.4-uuid php8.4-xdebug php8.4-xml php8.4-xmlrpc php8.4-xsl php8.4-yaml \
    php8.4-zip libapache2-mod-php8.4 1> /dev/null

# PHP 8.4 oci8 빌드 및 설치
echo "PHP 8.4용 Oci8 빌드 및 설치"
build_oci8 8.4 3.4.1

# PHP 8.5 설치
echo "PHP 8.5 설치"
sudo apt-get install -y --fix-missing php8.5-amqp php8.5-apcu php8.5-bcmath php8.5-bz2 php8.5-cli php8.5-curl php8.5-dba \
    php8.5-dev php8.5-ds php8.5-enchant php8.5-gd php8.5-gearman php8.5-gmp php8.5-gnupg php8.5-http php8.5-igbinary \
    php8.5-imagick php8.5-imap php8.5-intl php8.5-ldap php8.5-mailparse php8.5-mbstring php8.5-mcrypt \
    php8.5-memcache php8.5-mongodb php8.5-mysql php8.5-pgsql php8.5-raphf php8.5-rdkafka php8.5-readline \
    php8.5-redis php8.5-soap php8.5-sqlite3 php8.5-uuid php8.5-xdebug php8.5-xml php8.5-xmlrpc php8.5-xsl php8.5-yaml \
    php8.5-zip libapache2-mod-php8.5 1> /dev/null

# PHP 8.5 oci8 빌드 및 설치
echo "PHP 8.5용 Oci8 빌드 및 설치"
build_oci8 8.5 3.4.1

# oci8 소스 파일 제거
echo "Oci8 소스 제거"
cd
sudo rm -rf $HOMEDIR/oci8 1> /dev/null

# PHP 7.4 환경 설정 수정
echo "PHP 7.4 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.4/apache2/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/apache2/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/7.4/apache2/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.4/apache2/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee -a /etc/php/7.4/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=127.0.0.1" | sudo tee -a /etc/php/7.4/mods-available/xdebug.ini; \
sudo echo "xdebug.discover_client_host=1" | sudo tee -a /etc/php/7.4/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/7.4/mods-available/xdebug.ini

# PHP 8.1 환경 설정 수정
echo "PHP 8.1 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.1/apache2/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.1/apache2/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.1/apache2/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.1/apache2/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee -a /etc/php/8.1/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=xdebug://gateway" | sudo tee -a /etc/php/8.1/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/8.1/mods-available/xdebug.ini

# PHP 8.2 환경 설정 수정
echo "PHP 8.2 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.2/apache2/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.2/apache2/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.2/apache2/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.2/apache2/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee -a /etc/php/8.2/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=xdebug://gateway" | sudo tee -a /etc/php/8.2/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/8.2/mods-available/xdebug.ini

# PHP 8.4 환경 설정 수정
echo "PHP 8.4 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.4/apache2/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.4/apache2/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.4/apache2/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.4/apache2/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee -a /etc/php/8.4/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=xdebug://gateway" | sudo tee -a /etc/php/8.4/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/8.4/mods-available/xdebug.ini

# PHP 8.5 환경 설정 수정
echo "PHP 8.5 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.5/apache2/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.5/apache2/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.5/apache2/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.5/apache2/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee -a /etc/php/8.5/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=xdebug://gateway" | sudo tee -a /etc/php/8.5/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/8.5/mods-available/xdebug.ini

# composer 설치
echo "Composer 설치"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" 1> /dev/null
sudo php composer-setup.php --install-dir=/bin --filename=composer 1> /dev/null
rm -f composer-setup.php 1> /dev/null

# PHPMyAdmin 설치
echo "PHPMyAdmin 설치"
cd ~
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.tar.gz
tar xvzf phpMyAdmin-5.2.3-all-languages.tar.gz > /dev/null
sudo mv phpMyAdmin-5.2.3-all-languages /var/www/html/myadmin
sudo cp /var/www/html/myadmin/config.sample.inc.php /var/www/html/myadmin/config.inc.php 
echo "" | sudo tee --append /var/www/html/myadmin/config.inc.php
echo "\$cfg['AllowArbitraryServer'] = true;" | sudo tee --append /var/www/html/myadmin/config.inc.php
echo "\$cfg['CookieSecure'] = false;" | sudo tee --append /var/www/html/myadmin/config.inc.php
sudo chmod a+w /var/lib/php/sessions
rm -rf phpMyAdmin-5.2.3-all-languages.tar.gz

#NVM 설치
echo "NVM 설치"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
echo ".bash_profile 생성"
tee ~/.bash_profile > /dev/null <<BASHPROFILE
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
BASHPROFILE
export NVM_DIR="$HOMEDIR/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
echo "NodeJS 최신 LTS 버전 설치"
nvm install --lts

# 사용자 홈 디렉토리 접근 권한 설정
echo "사용자 홈 디렉토리 접근 권한 설정"
chmod a+x "$HOMEDIR"

# 대시보드 스크립트 설치
echo "대시보드 스크립트 설치"
sudo tee /var/www/html/index.php > /dev/null <<DASHBOARD
<?php
    function checkSites() {
        if(file_exists('/etc/apache2/sites-enabled/sites.conf')) return 1;
        elseif(file_exists('/etc/apache2/sites-enabled/domains.conf')) return 0;
        else return -1;
    }

    \$is_sites = checkSites();
    \$part_name = null;
    if(\$is_sites == 1) \$part_name = '일반';
    elseif(\$is_sites == 0) \$part_name = '도매인 사이트';
    else \$part_name = '미설정';

    \$domain_suffix = "wd";
    \$sites = array();
    \$docroots = array(
        'docroot', 'html', 'public_html', 'public', 'web', 'webroot', 'www', 'wwwroot'
    );

    \$base = "$HOMEDIR/projects";

    \$dh = opendir( \$base );
    if( \$dh ) {
        while( (\$entry = readdir( \$dh )) ) {
            if(\$is_sites == 1) {
                foreach( \$docroots as \$docroot ) {
                    if( \$entry == '..' || \$entry == '.' ) continue;
                    if( \$is_sites == 1 && filetype( \$base . '/' . \$entry . '/' . \$docroot ) == 'dir' ) {
                        \$sites[] = array(
                            'https_url' => "https://\$docroot.\$entry.\$domain_suffix",
                            'http_url' => "http://\$docroot.\$entry.\$domain_suffix",
                            'sitename' => \$entry
                        );
                    }
                }
            }
            elseif(\$is_sites == 0) {
                if( \$entry == '..' || \$entry == '.' ) continue;
                if(filetype(\$base . '/' . \$entry) == 'dir') {
                    \$sites[] = array(
                        'https_url' => "https://www.\$entry.\$domain_suffix",
                        'http_url' => "http://www.\$entry.\$domain_suffix",
                        'sitename' => \$entry
                    );
                }
            }
        }
    }
?>

<!DOCTYPE html>
    <html lang="ko">
    <head>
        <meta charset="UTF-8"/>
        <title>Site Helper</title>
        <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
    </head>
    <body>
        <nav class="navbar navbar-expand-lg navbar-light bg-light">
            <a class="navbar-brand" href="#">Site Helper</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item">
                        <a href="./myadmin" title="phpMyAdmin">데이터베이스 관리</a>
                    </li>
                    <li class="nav-item text-secondary ml-4">
                        <?=\$base?>
                    </li>
                </ul>
            </div>
        </nav>

        <div class="container mt-5">
            <div class="card">
                <div class="card-header">사이트 목록 (<?=\$part_name?>)</div>
                <div class="card-body">
                    <?php foreach( \$sites as \$site ): ?>
                        <div class="d-inline-block rounded m-2 bg-white" style="box-shadow: 1px 1px 10px 1px #aaa">
                            <div class="d-inline-block px-4 py-2 bg-info text-white"><?=\$site['sitename']?></div>
                            <div class="d-inline-block p-2">
                                <a class="m-1 p-1 text-success" href="<?=\$site['https_url']?>" title="https">https</a>
                                <a class="m-1 p-1 text-secondary" href="<?=\$site['http_url']?>" title="http">http</a>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>

        <div class="container mt-5">
            <div class="card">
                <div class="card-header">시스템 정보</div>
                <div class="card-body">
                    <?php phpinfo(); ?>
                </div>
            </div>
        </div>
    </body>
</html>
DASHBOARD

# PHP 버전 변경 스크립트 설치
SPHP_DIR="/usr/local/bin/sphp"
sudo tee "$SPHP_DIR" > /dev/null <<SPHP
#!/bin/bash

if [ -z "\$1" ]; then
    echo "sphp <Version>"
    echo "Version : 7.4, 8.1, 8.2, 8.4, 8.5"
    exit
fi

VERSION="\$1"
PHP_BIN="/usr/bin/php\${VERSION}"
PHP_CONFIG_BIN="/usr/bin/php-config\${VERSION}"
PHPIZE_BIN="/usr/bin/phpize\${VERSION}"
PHAR_BIN="/usr/bin/phar\${VERSION}"
PHAR_PHAR_BIN="/usr/bin/phar.phar\${VERSION}"

if [ ! -x "\$PHP_BIN" ]; then
    echo "\${PHP_BIN}을 찾을 수 없습니다."
    exit
else
    sudo update-alternatives --set php "\$PHP_BIN"
fi

if [ ! -x "\$PHP_CONFIG_BIN" ]; then
    echo "\${PHP_CONFIG_BIN}을 찾을 수 없습니다."
    exit
else
    sudo update-alternatives --set php-config "\$PHP_CONFIG_BIN"
fi

if [ ! -x "\$PHPIZE_BIN" ]; then
    echo "\${PHPIZE_BIN}을 찾을 수 없습니다."
    exit
else
    sudo update-alternatives --set phpize "\$PHPIZE_BIN"
fi

if [ ! -x "\$PHAR_BIN" ]; then
    echo "\${PHAR_BIN}을 찾을 수 없습니다."
    exit
else
    sudo update-alternatives --set phar "\$PHAR_BIN"
fi

if [ ! -x "\$PHAR_PHAR_BIN" ]; then
    echo "\${PHAR_PHAR_BIN}을 찾을 수 없습니다."
    exit
else
    sudo update-alternatives --set phar.phar "\$PHAR_PHAR_BIN"
fi

# Apache mod_php 버전 전환
APACHE_MOD="php\${VERSION}"
if [ -f "/etc/apache2/mods-available/\${APACHE_MOD}.load" ]; then
    for MOD_LOAD in /etc/apache2/mods-enabled/php*.load; do
        [ -e "\$MOD_LOAD" ] || continue
        sudo a2dismod -q "\$(basename "\$MOD_LOAD" .load)"
    done
    sudo a2enmod -q "\$APACHE_MOD"
    sudo service apache2 restart
else
    echo "Apache 모듈 \${APACHE_MOD}을 찾을 수 없습니다."
fi

ls -al /etc/alternatives/php*
SPHP
sudo chmod a+x "$SPHP_DIR"

# 개발환경 모드 변경 스크립트 설치
echo "개발환경 모드 변경 스크립트 설치"
SVHOST_DIR="/usr/local/bin/svhost"
sudo tee "$SVHOST_DIR" > /dev/null <<SVHOST
#!/bin/bash

if [[ "\$1" != "sites" && "\$1" != "domains" ]]; then
    echo "usage : svhost <sites|domains>"
    exit
fi

PROFILE="\$1"
CONF_DIR="/etc/apache2/sites-available/\${PROFILE}.conf"

if [ ! -f "\$CONF_DIR" ]; then
    echo "\$CONF_DIR not found"
    exit
fi

case \$1 in 
    sites)
        sudo a2dissite domains
        sudo a2ensite sites
        sudo service apache2 restart
        ;;
    domains)
        sudo a2dissite sites
        sudo a2ensite domains
        sudo service apache2 restart
        ;;
    *)
        echo "잘 못된 파라메터입니다니다."
        echo "usage : svhost <sites|domains>"
        ;;
esac
SVHOST

sudo chmod a+x "$SVHOST_DIR"

# 자체 서명 인증서 생성
echo "자체 서명 인증서 생성 중"
SSL_DIR="/etc/ssl/private/dev"
BASE_DOMAIN="wd"
COMMON_NAME="*.${BASE_DOMAIN}"
DAYS_EXPIRED=36500
SNIPPET="/etc/apache2/conf-available/dev_ssl.conf"

sudo mkdir -p "$SSL_DIR"
sudo chmod 700 "$SSL_DIR"

if [[ ! -f "$SSL_DIR/ca.key" ]]; then
  echo "🔐 로컬 CA 키 생성: $SSL_DIR/ca.key"
  sudo openssl genrsa -out "$SSL_DIR/ca.key" 4096
  sudo chmod 600 "$SSL_DIR/ca.key"
fi

if [[ ! -f "$SSL_DIR/ca.crt" ]]; then
  echo "🪪 로컬 CA 인증서 생성: $SSL_DIR/ca.crt"
  sudo openssl req -x509 -new -nodes \
    -key "$SSL_DIR/ca.key" \
    -sha256 -days "$DAYS_EXPIRED" \
    -subj "/CN=Local ${BASE_DOMAIN^^} Dev CA" \
    -out "$SSL_DIR/ca.crt"
  sudo chmod 644 "$SSL_DIR/ca.crt"
fi

# 서버 인증서 발급 스크립트 설치
# 와일드카드는 한 단계만 덮고 브라우저는 *.wd 같은 TLD 바로 아래 와일드카드를 거부하므로,
# ~/projects 아래 프로젝트마다 *.<프로젝트>.wd 를 SAN에 넣어 발급한다.
# 프로젝트를 추가한 뒤에는 sslcert 를 다시 실행하면 된다.
SSLCERT_DIR="/usr/local/bin/sslcert"
sudo tee "$SSLCERT_DIR" > /dev/null <<SSLCERT_VARS
#!/bin/bash
SSL_DIR="$SSL_DIR"
BASE_DOMAIN="$BASE_DOMAIN"
PROJECTS_DIR="$HOMEDIR/projects"
DAYS_EXPIRED=$DAYS_EXPIRED
SSLCERT_VARS
sudo tee -a "$SSLCERT_DIR" > /dev/null <<'SSLCERT'
set -e

SERVER_KEY="$SSL_DIR/${BASE_DOMAIN}.key"
SERVER_CSR="$SSL_DIR/${BASE_DOMAIN}.csr"
SERVER_CRT="$SSL_DIR/${BASE_DOMAIN}.crt"
EXT_CFG="$SSL_DIR/${BASE_DOMAIN}.ext"

SANS=("server.${BASE_DOMAIN}" "admin.sites.${BASE_DOMAIN}")
if [ -d "$PROJECTS_DIR" ]; then
    for PROJECT_PATH in "$PROJECTS_DIR"/*/; do
        [ -d "$PROJECT_PATH" ] || continue
        PROJECT=$(basename "$PROJECT_PATH")
        PROJECT=${PROJECT,,}
        if [[ "$PROJECT" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
            SANS+=("*.${PROJECT}.${BASE_DOMAIN}")
        else
            echo "건너뜀 (도메인으로 쓸 수 없는 이름): $PROJECT"
        fi
    done
fi

if ! sudo test -f "$SERVER_KEY"; then
    echo "🔑 서버 키 생성: $SERVER_KEY"
    sudo openssl genrsa -out "$SERVER_KEY" 2048 2> /dev/null
    sudo chmod 600 "$SERVER_KEY"
fi

sudo openssl req -new -key "$SERVER_KEY" -subj "/CN=server.${BASE_DOMAIN}" -out "$SERVER_CSR"

{
    echo "authorityKeyIdentifier=keyid,issuer"
    echo "basicConstraints=CA:FALSE"
    echo "keyUsage = digitalSignature,keyEncipherment"
    echo "extendedKeyUsage = serverAuth"
    echo "subjectAltName = @alt_names"
    echo ""
    echo "[alt_names]"
    for i in "${!SANS[@]}"; do
        echo "DNS.$((i + 1))=${SANS[$i]}"
    done
} | sudo tee "$EXT_CFG" > /dev/null

sudo openssl x509 -req -in "$SERVER_CSR" \
    -CA "$SSL_DIR/ca.crt" -CAkey "$SSL_DIR/ca.key" -CAcreateserial \
    -out "$SERVER_CRT" -days "$DAYS_EXPIRED" -sha256 \
    -extfile "$EXT_CFG" 2> /dev/null
sudo chmod 644 "$SERVER_CRT"

echo "✍️  서버 인증서 발급: $SERVER_CRT"
printf '    %s\n' "${SANS[@]}"

if service apache2 status > /dev/null 2>&1; then
    sudo service apache2 reload > /dev/null
fi
SSLCERT
sudo chmod a+x "$SSLCERT_DIR"

mkdir -p "$HOMEDIR/projects"
sslcert

# Apache2 환경설정 파일 생성
echo "Ahache2 환경설정 파일 생성"
VHOSTDIR="/etc/apache2/sites-available"

# 기본 설정 파일 생성
sudo tee "$VHOSTDIR/default.conf" > /dev/null << DEFAULT_CONF
<VirtualHost *:80>
    ServerName admin.sites.wd
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>
</VirtualHost>
DEFAULT_CONF

# 사이트단위 가상호스트 설정
sudo tee "$VHOSTDIR/sites.conf" > /dev/null << SITES_CONF
<VirtualHost *:80>
    ServerName server.wd
    ServerAlias *.*.wd
    UseCanonicalName Off

    ServerAdmin webmaster@localhost
    VirtualDocumentRoot $HOMEDIR/projects/%2/%1

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory $HOMEDIR/projects/*/*>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:443>
    ServerName server.wd
    ServerAlias *.*.wd
    UseCanonicalName Off

    ServerAdmin webmaster@localhost
    VirtualDocumentRoot $HOMEDIR/projects/%2/%1

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory $HOMEDIR/projects/*/*>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateKeyFile ${SSL_DIR}/${BASE_DOMAIN}.key
    SSLCertificateFile ${SSL_DIR}/${BASE_DOMAIN}.crt
</VirtualHost>
SITES_CONF

# 도매인단위 사이트 환경설정
sudo tee "$VHOSTDIR/domains.conf" > /dev/null << DOMAINS_CONF
<VirtualHost *:80>
    ServerName server.wd
    ServerAlias *.*.wd

    ServerAdmin webmaster@localhost
    VirtualDocumentRoot $HOMEDIR/projects/%2/docroot

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory $HOMEDIR/projects/*/docroot>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:443>
    ServerName server.wd
    ServerAlias *.*.wd

    ServerAdmin webmaster@localhost
    VirtualDocumentRoot $HOMEDIR/projects/%2/public

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory $HOMEDIR/projects/*/public>
        DirectoryIndex index.php index.html index.htm
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        Allow from All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateKeyFile ${SSL_DIR}/${BASE_DOMAIN}.key
    SSLCertificateFile ${SSL_DIR}/${BASE_DOMAIN}.crt
</VirtualHost>
DOMAINS_CONF

# Apache2 Listen 설정
# WSL(consomme 등) 포트 포워딩은 Apache가 bind한 주소 체계 그대로 Windows에 포트를 연다.
# 기본 'Listen 80'은 [::] 듀얼스택 소켓 하나만 만들어 Windows에는 IPv6 포트만 열리고
# 127.0.0.1 접속이 거부된다. [::]와 0.0.0.0을 함께 적어도 Apache가 IPv4를 생략하므로
# IPv4 전용으로 Listen 한다.
echo "Apache2 Listen 설정 (IPv4)"
sudo tee /etc/apache2/ports.conf > /dev/null <<'PORTS_CONF'
# IPv4 명시 (WSL 포트 포워딩 대응)
Listen 0.0.0.0:80

<IfModule ssl_module>
	Listen 0.0.0.0:443
</IfModule>

<IfModule mod_gnutls.c>
	Listen 0.0.0.0:443
</IfModule>
PORTS_CONF

# Apache2 모듈 및 사이트 활성화
echo "Apache2 모듈 및 사이트 활성화"
sudo a2enmod -q vhost_alias ssl rewrite
sudo a2dissite -q 000-default
sudo a2ensite -q default
svhost domains

# 기본 PHP 버전 설정 (CLI + Apache mod_php)
sphp 8.5

sudo apache2ctl configtest