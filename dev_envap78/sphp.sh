#!/bin/bash

if [ "$1" == "7.4" ]; then
    a2enmod php7.4
    update-alternatives --set php /usr/bin/php7.4
elif [ "$1" == "8.0" ]; then
    a2enmod php8.0
    update-alternatives --set php /usr/bin/php8.0
elif [ "$1" == "8.1" ]; then
    a2enmod php8.1
    update-alternatives --set php /usr/bin/php8.1
elif [ "$1" == "8.2" ]; then
    a2enmod php8.2
    update-alternatives --set php /usr/bin/php8.2
elif [ "$1" == "8.4" ]; then
    a2enmod php8.4
    update-alternatives --set php /usr/bin/php8.4
fi