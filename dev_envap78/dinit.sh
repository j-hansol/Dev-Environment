#!/bin/bash

PHP=""
CONF=""
CUSTOM_INI=""
DOCUMENT_ROOT=""

EXIT=0
while [ $EXIT -eq 0 ]
do
    echo " 1. Init Directory (webroot, webroot/sites, webroot/domains, lib) "
    echo ""
    echo " Domains Evironment "
    echo " 2. PHP 7.4 "
    echo " 3. PHP 8.1 "
    echo " 4. PHP 8.2 "
    echo " 5. PHP 8.4 "
    echo ""
    echo " Sites Environment "
    echo " 6. PHP 7.4 "
    echo " 7. PHP 8.1 "
    echo " 8. PHP 8.2 "
    echo " 9. PHP 8.4 "
    echo " 0. Exit "
    
    read -p "Select Number : " NO
    case "$NO" in
        1)
            mkdir webroot 2> /dev/null
            mkdir -p webroot/sites 2> /dev/null
            mkdir -p webroot/domains 2> /dev/null
            mkdir -p lib 2> /dev/null
            ;;
        2)
            PHP="7.4"
            CONF="domains"
            EXIT=1
            ;;
        3)
            PHP="8.1"
            CONF="domains"
            EXIT=1
            ;;
        4)
            PHP="8.2"
            CONF="domains"
            EXIT=1
            ;;
        5)
            PHP="8.4"
            CONF="domains"
            EXIT=1
            ;;
        6)
            PHP="7.4"
            CONF="sites"
            EXIT=1
            ;;
        7)
            PHP="8.1"
            CONF="sites"
            EXIT=1
            ;;
        8)
            PHP="8.2"
            CONF="sites"
            EXIT=1
            ;;
        9)
            PHP="8.4"
            CONF="sites"
            EXIT=1
            ;;
        0)
            exit 0
            ;;
        *)
            echo " Wrong number."
            ;;
    esac
done

if [ $EXIT -eq 1 ]; then
    read -p "PHP Custom extension ini file name : " INI
    if [ -f "./lib/${INI}" ]; then
        CUSTOM_INI=$INI
    fi

    read -p "Type Document root directory name (Domains only) : " DIR
    DOCUMENT_ROOT=$DIR
    
    if [ -f "docker-compose.yml" ]; then
        rm -f docker-compose.yml
    fi

    echo "name: PHP_DEV" > docker-compose.yml
    echo "" >> docker-compose.yml
    echo "volumes:" >> docker-compose.yml
    echo "  sql_data:" >> docker-compose.yml
    echo "" >> docker-compose.yml
    echo "services:" >> docker-compose.yml
    echo "  db:" >> docker-compose.yml
    echo "    image: mariadb" >> docker-compose.yml
    echo "    command: --max_allowed_packet=536870912" >> docker-compose.yml
    echo "    environment:" >> docker-compose.yml
    echo "      MARIADB_ROOT_PASSWORD: mysql" >> docker-compose.yml
    echo "    ports:" >> docker-compose.yml
    echo "      - 3306:3306" >> docker-compose.yml
    echo "    volumes:" >> docker-compose.yml
    echo "      - sql_data:/var/lib/mysql" >> docker-compose.yml
    echo "" >> docker-compose.yml
    echo "  web:" >> docker-compose.yml
    echo "    image: pig482/devenv:ap78" >> docker-compose.yml
    echo "    environment:" >> docker-compose.yml
    echo "      PHP: ${PHP}" >> docker-compose.yml
    echo "      CONF: ${CONF}" >> docker-compose.yml
    
    if [ -n "./lib/${CUSTOM_INI}" ]; then
        echo "      CUSTOM_INI: ${CUSTOM_INI}" >> docker-compose.yml
    fi
    
    echo "      DOCUMENT_ROOT: ${DOCUMENT_ROOT}" >> docker-compose.yml
    echo "    ports:" >> docker-compose.yml
    echo "      - 80:80" >> docker-compose.yml
    echo "      - 443:443" >> docker-compose.yml
    echo "      - 5173:5173" >> docker-compose.yml
    echo "      - 8080:8080" >> docker-compose.yml
    echo "    volumes:" >> docker-compose.yml
    echo "      - ./webroot:/DevHome" >> docker-compose.yml

    if [ -n "./lib/${CUSTOM_INI}" ]; then
        echo "      - ./lib:/usr/lib/php/custom" >> docker-compose.yml
    fi

    echo "Init docker-compose.yml file"
fi