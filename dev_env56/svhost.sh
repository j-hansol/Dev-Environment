#!/bin/bash

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
    file="/etc/apache2/sites-available/domains.conf"
    if [ -e $file ]; then
        sed -i "s/\/DevHome\/domains\/%2\/.*$/\/DevHome\/domains\/%2\/$1/g" $file
        sed -i "s/\/DevHome\/domains\/\*\/[^>]*/\/DevHome\/domains\/\*\/$1/g" $file
        if [ ! -e "/etc/apache2/sites-enabled/domains.conf" ]
        then
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
    if [ -e $file -a ! -e "/etc/apache2/sites-enabled/sites.conf" ]; then
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
        unlink "domains.conf"
        if [ $(sites_link) -eq 1 ]; then
            service apache2 reload
        else
            echo "Cannot switch mode."
        fi
        ;;
    domains)
        if [ -n $2 ]; then
            unlink "sites.conf"
            ret=$(domain_link $2)
            if [ 1 -eq $ret ]; then
                service apache2 reload
            else
                echo "Cannot switch mode."
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