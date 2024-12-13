#!/bin/bash

get_current() {
    if [ -e "/etc/apache2/mods-enabled/php7.4.conf" ]; then
        echo "7.4"
    elif [ -e "/etc/apache2/mods-enabled/php8.2.conf" ]; then
        echo "8.2"
    elif [ -e "/etc/apache2/mods-enabled/php8.4.conf" ]; then
        echo "8.4"
    else 
        echo "None"
    fi
}

apache2_restart() {
    service apache2 stop
    service apache2 start
}

case $1 in
    7.4)
        target="7.4"
        ;;
    8.2)
        target="8.2"
        ;;
    8.4)
        target="8.4"
        ;;
    *)
        echo "Usage : sphp <7.4|8.2|8.4>" %>2
        exit 1
esac

current=$( get_current )
if [ "$1" == "${current}" ]; then
    echo "$1 is already actived" %>2
    exit 1
fi

if [ "$target" == "7.4" ]; then
    a2dismod "php$current"
    a2enmod php7.4
    apache2_restart
    update-alternatives --set php /usr/bin/php7.4
    echo "Done..."
elif [ "$target" == "8.2" ]; then
    a2dismod "php$current"
    a2enmod php8.2
    apache2_restart
    update-alternatives --set php /usr/bin/php8.2
    echo "Done..."
elif [ "$target" == "8.4" ]; then
    a2dismod "php$current"
    a2enmod php8.4
    apache2_restart
    update-alternatives --set php /usr/bin/php8.4
    echo "Done..."
fi