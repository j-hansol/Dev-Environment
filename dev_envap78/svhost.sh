#!/bin/bash

# 도메인 기반 사이트 환경설정 활성화
function domain_link()
{
    file="/etc/apache2/sites-available/domains.conf"
    if [ -e $file ]; then
        sed -i "s/\/DevHome\/domains\/%2\/.*$/\/DevHome\/domains\/%2\/$1/g" $file
        sed -i "s/\/DevHome\/domains\/%1\/.*$/\/DevHome\/domains\/%1\/$1/g" $file
        sed -i "s/\/DevHome\/domains\/\*\/[^>]*/\/DevHome\/domains\/\*\/$1/g" $file
        if [ ! -e "/etc/apache2/sites-enabled/domains.conf" ]; then
            ln -s $file "/etc/apache2/sites-enabled/domains.conf"
        fi
        echo 1
    else
        echo 0;
    fi
}

# 개별 사이트 환경설정 활성화
function sites_link()
{
    file="/etc/apache2/sites-available/sites.conf"
    if [ -e $file ]; then
        if [ ! -e "/etc/apache2/sites-enabled/sites.conf" ]; then
            ln -s $file "/etc/apache2/sites-enabled/sites.conf"
        fi
        echo 1
    else
        echo 0
    fi
}

case $1 in
    sites)
        sites_link
        ;;
    domains)
         domain_link $2
        ;;
esac
