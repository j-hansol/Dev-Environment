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