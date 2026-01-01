#!/bin/bash

if[ "$1" == "apache" ]; then
    service nginx stop;
    service php7.4-fpm stop
    service php8.1-fpm stop
    service php8.2-fpm stop
    service php8.3-fpm stop
    systemctl disable nginx
    systemctl disable php7.4-fpm
    systemctl disable php8.1-fpm
    systemctl disable php8.2-fpm
    systemctl disable php8.3-fpm
    systemctl enable apache2
    service apache2 start
else 
    service apache2 stop
    systemctl disable apache2
    systemctl enable nginx
    systemctl enable php7.4-fpm
    systemctl enable php8.1-fpm
    systemctl enable php8.2-fpm
    systemctl enable php8.3-fpm
    service nginx start;
    service php7.4-fpm start
    service php8.1-fpm start
    service php8.2-fpm start
    service php8.3-fpm start
fi