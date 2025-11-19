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
sudo apt-get install -y zip unzip libpng-dev bind9-dnsutils nginx librsvg2-bin fswatch openssl 1> /dev/null

# PHP 패키지 저장소 추가
echo "PHP 패키지 저장소 추가"
sudo add-apt-repository -y ppa:ondrej/php 1> /dev/null
sudo apt-get update 1> /dev/null

# Oracle 데이터베이스 연결용 라이브러리 설치
echo "Oracle Instant Client 라이브러리 설치"
sudo mkdir /usr/lib/oracle 1> /dev/null
cd /usr/lib/oracle 1> /dev/null
sudo wget https://download.oracle.com/otn_software/linux/instantclient/2119000/instantclient-basic-linux.x64-21.19.0.0.0dbru.zip 1> /dev/null
sudo unzip -o instantclient-basic-linux.x64-21.19.0.0.0dbru.zip 1> /dev/null
sudo rm -rf instantclient-basic-linux.x64-21.19.0.0.0dbru.zip 1> /dev/null
sudo wget https://download.oracle.com/otn_software/linux/instantclient/2119000/instantclient-sdk-linux.x64-21.19.0.0.0dbru.zip 1> /dev/null
sudo unzip -o instantclient-sdk-linux.x64-21.19.0.0.0dbru.zip 1> /dev/null
sudo rm -rf instantclient-sdk-linux.x64-21.19.0.0.0dbru.zip 1> /dev/null
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
    php7.4-mbstring php7.4-zip php7.4-redis php7.4-imagick php7.4-xdebug php7.4-fpm 1> /dev/null

# oci8 소스 다운르도
echo "Oci8 확장 소스 다운로드"
sudo apt-get -y install glibc-source php-pear build-essential libaio1t64 1> /dev/null
mkdir -p $HOMEDIR/oci8 1> /dev/null
cd $HOMEDIR/oci8 1> /dev/null
pecl download oci8-2.2.0 1> /dev/null
tar xvzf oci8-2.2.0.tgz 1> /dev/null
rm oci8-2.2.0.tgz 1> /dev/null
pecl download oci8-3.2.1 1> /dev/null
tar xvzf oci8-3.2.1.tgz 1> /dev/null
rm oci8-3.2.1.tgz 1> /dev/null
pecl download oci8-3.3.0 1> /dev/null
tar xvzf oci8-3.3.0.tgz 1> /dev/null
rm oci8-3.3.0.tgz 1> /dev/null
pecl download oci8-3.4.0 1> /dev/null
tar xvzf oci8-3.4.0.tgz 1> /dev/null
rm oci8-3.4.0.tgz 1> /dev/null

# PHP 7.4용 Oci8 빌드 및 설치
echo "PHP 7.4 Oci8 확장 빌드 및 설치"
cd $HOMEDIR/oci8/oci8-2.2.0 1> /dev/null
phpize7.4 1> /dev/null
./configure --with-php-config=/usr/bin/php-config7.4 \
  --with-oci8=instantclient,$LD_LIBRARY_PATH 2>&1 | tee $HOMEDIR/oci8/oci8-7.4-configure.log 1> /dev/null
sudo make install >> $HOMEDIR/oci8/oci8-7.4-configure.log
echo "extension=oci8.so" | sudo tee /etc/php/7.4/mods-available/oci8.ini >/dev/null
sudo phpenmod oci8 1> /dev/null


# PHP 8.1 설치
echo "PHP 8.1 설치"
sudo apt-get install -y --fix-missing php8.1-amqp php8.1-apcu php8.1-bcmath php8.1-bz2 php8.1-cli php8.1-curl php8.1-dba \
    php8.1-dev php8.1-ds php8.1-enchant php8.1-gd php8.1-gearman php8.1-gnupg php8.1-gmp php8.1-http \
    php8.1-igbinary php8.1-imagick php8.1-imap php8.1-intl php8.1-ldap php8.1-mailparse php8.1-mbstring php8.1-mcrypt \
    php8.1-mysql php8.1-memcache php8.1-mongodb php8.1-opcache php8.1-pgsql php8.1-readline php8.1-raphf \
    php8.1-rdkafka php8.1-readline php8.1-redis php8.1-soap php8.1-solr php8.1-sqlite3 php8.1-uuid php8.1-xml \
    php8.1-xmlrpc php8.1-xsl php8.1-zip php8.1-xdebug php8.1-yaml php8.1-fpm 1> /dev/null

# PHP 8.1용 oci8 빌드 및 설치
echo "PHP 8.1용 Oci8 빌드 및 설치"
cd $HOMEDIR/oci8/oci8-3.2.1 1> /dev/null
phpize8.1 1> /dev/null
./configure --with-php-config=/usr/bin/php-config8.1 \
  --with-oci8=instantclient,$LD_LIBRARY_PATH 2>&1 | tee $HOMEDIR/oci8/oci8-8.1-configure.log 1> /dev/null
sudo make install >> $HOMEDIR/oci8/oci8-8.1-configure.log
echo "extension=oci8.so" | sudo tee /etc/php/8.1/mods-available/oci8.ini >/dev/null
sudo phpenmod oci8 1> /dev/null

# PHP 8.2 설치
echo "PHP 8.2 설치"
sudo apt-get install -y --fix-missing php8.2-amqp php8.2-apcu php8.2-bcmath php8.2-bz2 php8.2-cli php8.2-curl php8.2-dba \
    php8.2-dev php8.2-ds php8.2-enchant php8.2-gd php8.2-gearman php8.2-gnupg php8.2-gmp php8.2-http php8.2-igbinary \
    php8.2-imagick php8.2-imap php8.2-intl php8.2-ldap php8.2-mailparse php8.2-mbstring php8.2-mcrypt php8.2-mysql \
    php8.2-memcache php8.2-mongodb php8.2-opcache php8.2-pgsql php8.2-readline php8.2-raphf php8.2-rdkafka \
    php8.2-readline php8.2-redis php8.2-soap php8.2-solr php8.2-sqlite3 php8.2-uuid php8.2-xml php8.2-xmlrpc \
    php8.2-xsl php8.2-zip php8.2-xdebug php8.2-yaml php8.2-fpm 1> /dev/null

# PHP 8.2 oci8 빌드 및 설치
echo "PHP 8.2용 Oci8 빌드 및 설치"
cd $HOMEDIR/oci8/oci8-3.3.0 1> /dev/null
phpize8.2 1> /dev/null
./configure --with-php-config=/usr/bin/php-config8.2 \
  --with-oci8=instantclient,$LD_LIBRARY_PATH 2>&1 | tee $HOMEDIR/oci8/oci8-8.2-configure.log 1> /dev/null
sudo make install >> $HOMEDIR/oci8/oci8-8.2-configure.log
echo "extension=oci8.so" | sudo tee /etc/php/8.2/mods-available/oci8.ini >/dev/null
sudo phpenmod oci8 1> /dev/null

# PHP 8.4 설치
echo "PHP 8.4 설치"
sudo apt-get install -y --fix-missing php8.4-amqp php8.4-apcu php8.4-bcmath php8.4-bz2 php8.4-cli php8.4-curl php8.4-dba \
    php8.4-dev php8.4-ds php8.4-enchant php8.4-gd php8.4-gearman php8.4-gmp php8.4-gnupg php8.4-http php8.4-igbinary \
    php8.4-imagick php8.4-imap php8.4-intl php8.4-ldap php8.4-mailparse php8.4-mbstring php8.4-mcrypt php8.4-mcrypt \
    php8.4-memcache php8.4-mongodb php8.4-mysql php8.4-opcache php8.4-pgsql php8.4-raphf php8.4-rdkafka php8.4-readline \
    php8.4-redis php8.4-soap php8.4-sqlite3 php8.4-uuid php8.4-xdebug php8.4-xml php8.4-xmlrpc php8.4-xsl php8.4-yaml \
    php8.4-zip php8.4-fpm 1> /dev/null

# PHP 8.4 oci8 빌드 및 설치
echo "PHP 8.4용 Oci8 빌드 및 설치"
cd $HOMEDIR/oci8/oci8-3.4.0 1> /dev/null
phpize8.4 1> /dev/null
./configure --with-php-config=/usr/bin/php-config8.4 \
  --with-oci8=instantclient,$LD_LIBRARY_PATH 2>&1 | tee $HOMEDIR/oci8/oci8-8.4-configure.log 1> /dev/null
sudo make install >> $HOMEDIR/oci8/oci8-8.4-configure.log
echo "extension=oci8.so" | sudo tee /etc/php/8.4/mods-available/oci8.ini >/dev/null
phpenmod oci8 1> /dev/null

# oci8 소스 파일 제거
echo "Oci8 소스 제거"
cd
sudo rm -rf $HOMEDIR/oci8 1> /dev/null

# PHP 7.4 환경 설정 수정
echo "PHP 7.4 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.4/fpm/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/fpm/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/7.4/fpm/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.4/fpm/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee /etc/php/7.4/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=127.0.0.1" | sudo tee -a /etc/php/7.4/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/7.4/mods-available/xdebug.ini

# PHP 8.1 환경 설정 수정
echo "PHP 8.1 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.1/fpm/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.1/fpm/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.1/fpm/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.1/fpm/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee /etc/php/8.1/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=127.0.0.1" | sudo tee -a /etc/php/8.1/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/8.1/mods-available/xdebug.ini

# PHP 8.2 환경 설정 수정
echo "PHP 8.2 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.2/fpm/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.2/fpm/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.2/fpm/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.2/fpm/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee /etc/php/8.2/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=127.0.0.1" | sudo tee -a /etc/php/8.2/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/8.2/mods-available/xdebug.ini

# PHP 8.4 환경 설정 수정
echo "PHP 8.4 환경 설정 수정"
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.4/fpm/php.ini; \
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/8.4/fpm/php.ini; \
sudo sed -i 's/post_max_size = 8M/post_max_size = 250M/g' /etc/php/8.4/fpm/php.ini; \
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.4/fpm/php.ini; \
sudo echo "xdebug.mode = develop,debug" | sudo tee /etc/php/8.4/mods-available/xdebug.ini; \
sudo echo "xdebug.client_host=127.0.0.1" | sudo tee -a /etc/php/8.4/mods-available/xdebug.ini; \
sudo echo "xdebug.client_port = 9000" | sudo tee -a /etc/php/8.4/mods-available/xdebug.ini

#PHP FPM 재실행
echo "모든 버전의 PHP FPM 재실행"
sudo service php7.4-fpm restart 1> /dev/null
sudo service php8.1-fpm restart 1> /dev/null
sudo service php8.2-fpm restart 1> /dev/null
sudo service php8.4-fpm restart 1> /dev/null

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
edho "사용자 홈 디렉토리 접근 권한 설정"
chmod a+x "$HOMEDIR"

# 대시보드 스크립트 설치
echo "대시보드 스크립트 설치"
sudo tee /var/www/html/index.php > /dev/null <<DASHBOARD
<?php
    function checkSites() {
        if(file_exists('/etc/nginx/sites-enabled/sites')) return 1;
        elseif(file_exists('/etc/nginx/sites-enabled/domains')) return 0;
        else return -1;
    }

    function getProjectRoot(\$site_type) {
        if(\$site_type == 0) \$conf = '/etc/nginx/sites-enabled/domains';
        elseif(\$site_type == 1) \$conf = '/etc/nginx/sites-enabled/sites';
        else return null;

        if(file_exists(\$conf)) {
            \$content = file_get_contents(\$conf, true);

            preg_match_all('/set\\s+\\\$project_root\\s+([^;]+);/m', \$content, \$matches);
            if(count(\$matches) == 2) {
                return reset(\$matches[1]);
            }
        }
        return null;
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

    \$base = getProjectRoot(\$is_sites);

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
                        break;
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
                    break;
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
    echo "Version : 7.4, 8.1, 8.2, 8.4"
    exit
fi

VERSION="\$1"
PHP_BIN="/usr/bin/php\${VERSION}"
PHP_CONFIG_BIN="/usr/bin/php-config\${VERSION}"
PHPIZE_BIN="/usr/bin/phpize\${VERSION}"
PHAR_BIN="/usr/bin/phar\${VERSION}"
PHAR_PHAR_BIN="/usr/bin/phar.phar\${VERSION}"
PHP_FPM_SOCKET="/run/php/php\${VERSION}-fpm.sock"

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

if [ ! -S "\$PHP_FPM_SOCKET" ]; then
    echo "\${PHP_FPM_SOCKET}을 찾을 수 없습니다."
    exit
else
    sudo update-alternatives --set php-fpm.sock "\$PHP_FPM_SOCKET"
fi

ls -al /etc/alternatives/php*
SPHP
sudo chmod a+x "$SPHP_DIR"


# 개발환경 모드 변경 스크립트 설치
echo "개발환경 모드 변경 스크립트 설치"
SVHOST_DIR="/usr/local/bin/svhost"
sudo tee "$SVHOST_DIR" > /dev/null <<SVHOST
#!/bin/bash

if [ -z "\$1" ]; then
    echo "svhost <domains|sites>"
    exit
fi

PROFILE="\$1"
CONF_DIR="/etc/nginx/sites-available/\${PROFILE}"
LINK_DIR="/etc/nginx/sites-enabled/\${PROFILE}"
LINK_FOLDER="/etc/nginx/sites-enabled"

if [ -f "\$CONF_DIR" ]; then
    sudo rm -rf "\${LINK_FOLDER}/domains" "\${LINK_FOLDER}/sites"
    sudo ln -s "\$CONF_DIR" "\$LINK_DIR"
    sudo service nginx restart
else
    echo "\${CONF_DIR}을 찾을 수 없습니다."
fi
SVHOST
sudo chmod a+x "$SVHOST_DIR"

# 자체 서명 인증서 생성
echo "자체 서명 인증서 생성 중"
SSL_DIR="/etc/ssl/private/dev"
BASE_DOMAIN="wd"
COMMON_NAME="*.${BASE_DOMAIN}"
DAYS_EXPIRED=36500
SNIPPET="/etc/nginx/conf.d/dev_ssl.conf"

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
    -subj "/CN=Local ${TARGET_DOMAIN^^} Dev CA" \
    -out "$SSL_DIR/ca.crt"
  sudo chmod 644 "$SSL_DIR/ca.crt"
fi

SERVER_KEY="$SSL_DIR/${BASE_DOMAIN}.key"
SERVER_CSR="$SSL_DIR/${BASE_DOMAIN}.csr"
SERVER_CRT="$SSL_DIR/${BASE_DOMAIN}.crt"
EXT_CFG="$SSL_DIR/${BASE_DOMAIN}.ext"

echo "🔑 서버 키 생성: $SERVER_KEY"
sudo openssl genrsa -out "$SERVER_KEY" 2048
sudo chmod 600 "$SERVER_KEY"

echo "📄 CSR 생성: $SERVER_CSR (CN=$COMMON_NAME)"
sudo openssl req -new -key "$SERVER_KEY" -subj "/CN=${COMMON_NAME}" -out "$SERVER_CSR"

echo "🧩 SAN 구성: $EXT_CFG"
cat <<EOF | sudo tee "$EXT_CFG"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=${COMMON_NAME}
EOF

echo "✍️  서버 인증서 발급: $SERVER_CRT"
sudo openssl x509 -req -in "$SERVER_CSR" \
  -CA "$SSL_DIR/ca.crt" -CAkey "$SSL_DIR/ca.key" -CAcreateserial \
  -out "$SERVER_CRT" -days "$DAYS_EXPIRED" -sha256 \
  -extfile "$EXT_CFG"
sudo chmod 644 "$SERVER_CRT"

echo "🧩 nginx SSL 스니펫 생성: $SNIPPET"
sudo tee "$SNIPPET" > /dev/null <<EOF
ssl_certificate     $SERVER_CRT;
ssl_certificate_key $SERVER_KEY;

ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1h;
ssl_ciphers HIGH:!aNULL:!MD5;
EOF

# Nginx 기본 서버 설정 변경
echo "Nginx 기본 서버 환경 설정 변경"
sudo tee /etc/nginx/sites-available/default > /dev/null <<DEFAULT_SERVER
client_header_timeout 600;
client_body_timeout 600;

server {
    server_name _;

    server_tokens off;

    listen 80 default_server;
    listen [::]:80 default_server;

    gzip on;
    gzip_types text/css text/x-component application/x-javascript application/javascript text/javascript text/x-js text/richtext image/svg+xml text/plain text/xsd text/xsl text/xml image/x-icon;
    gzip_disable "msie6";
    sendfile on;

    client_max_body_size 2G;

    root /var/www/html;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    charset utf-8;

    index index.php index.html index.htm;

    access_log  /var/log/nginx/default-access.log;
    error_log   /var/log/nginx/default-error.log info;

    add_header 'X-UA-Compatible' 'IE=Edge';

    location ~ /\. {
        deny all;
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    location ~ \.php$ {
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi.conf;
        fastcgi_hide_header X-Powered-By;
        fastcgi_pass unix:/etc/alternatives/php-fpm.sock;
    }
}
DEFAULT_SERVER

# 멀티도매인 환경설정
echo "멀티도매인 환경설정"
sudo tee /etc/nginx/sites-available/domains > /dev/null <<DOMAINS_CONFIG
server {
    listen 80;
    listen [::]:80;

    listen 443 ssl;
    listen [::]:443 ssl;

    index index.php index.html index.htm index.nginx-debian.html;

    access_log  /var/log/nginx/domains-access.log;
    error_log   /var/log/nginx/domains-error.log info;

    server_name ~^(?<organization>[\w\-]+)\.wd$;
    server_name ~^[\w\-]+\.(?<organization>[\w\-]+)\.wd$;

    include $SNIPPET;

    set \$project_root $HOMEDIR/projects;
    set \$domains \$project_root/\$organization/public;
    root \$domains;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi.conf;
        fastcgi_hide_header X-Powered-By;
        fastcgi_pass unix:/etc/alternatives/php-fpm.sock;
    }
}
DOMAINS_CONFIG

# 싱글 사이트 환경설정
echo "싱글 사이트 환경설정"
sudo tee /etc/nginx/sites-available/sites > /dev/null <<SITE_CONFIG
server {
    listen 80;
    listen [::]:80;

    listen 443 ssl;
    listen [::]:443 ssl;

    index index.php index.html index.htm index.nginx-debian.html;

    access_log  /var/log/nginx/sites-access.log;
    error_log   /var/log/nginx/sites-error.log info;

    server_name ~^(?<organization>[\w\-]+)\.wd$;
    server_name ~^(?<host_name>[\w\-]+)\.(?<organization>[\w\-]+)\.wd$;

    include $SNIPPET;

    set \$project_root $HOMEDIR/projects;
    set \$sites $HOMEDIR/projects/\$organization/\$host_name;
    root \$sites;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi.conf;
        fastcgi_hide_header X-Powered-By;
        fastcgi_pass unix:/etc/alternatives/php-fpm.sock;
    }
}
SITE_CONFIG

sudo ln -s /etc/nginx/sites-available/domains /etc/nginx/sites-enabled/domains

# Nginx 재실행
sudo service nginx restart