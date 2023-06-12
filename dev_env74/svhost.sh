#!/bin/bash

# 파일 체크
function check_available_conf()
{
    file="/etc/apache2/sites-available/$1"
    if [ -e $file ]; then
        return 1
    else
        return 0;
    fi
}
}

# 파일 섹제
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
    unlink("domains.conf")
    file="/etc/apache2/sites-available/$1"
    if [ -e $file ]; then
        ln -s $file "/etc/ahache2/sites-enabled/domains.conf"
        return 1
    else
        return 0;
    fi
}

# 개별 사이트 환경설정 활성화
function sites_link()
{
    unlink("sites.conf")
    file="/etc/apache2/sites-available/sites.conf"
    if [ -e $file ]; then
        ln -s $file "/etc/ahache2/sites-enabled/sites.conf"
        return 1
    else
        return 0
    fi
}

case $1 in
    init)
        if [ 1 -eq sites_link ]; then
            service apache2 start
        else
            echo "Initialization failed" %>2
        fi
        ;;
    sites)
        if [ 1 -eq check_available_conf("sites.conf") ]; then
            unlink("domains.conf")
            if [ 1 -eq sites_link ]; then
                service apache2 reload
            else
                echo "Cannot switch modes." %>2
            fi
        else
            echo "Cannot switch modes." %>2
        fi
        ;;
    domains)
        if [ -nz $2 ]; then
            if [ 1 -eq check_available_conf("domains.$2.conf") ]; then
                unlink("sites.conf")
                if [ 1 -eq domain_link("domains.$2.conf") ]; then
                    service apache2 reload
                else
                    echo "Cannot switch modes." %>2
                fi
            else
                echo "Cannot switch modes." %>2
            fi
        else
            echo "Type document root." %>2
        fi
        ;;
    start)
        service apache2 start
        ;;
    stop)
        service apache2 stop
        ;;
    *)
        echo "Usage : svhost <sites|domains> [document_root]" %>2
        ;;
esac

echo "Done..."