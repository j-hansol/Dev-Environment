#!/bin/bash

case $1 in
    init)
        a2ensite sites
        service apache2 start
        ;;
    sites)
        a2dissite site
        a2ensite sites
        service apache2 reload
        ;;
    site)
        a2dissite sites
        a2ensite site
        service apache2 reload
        ;;
    start)
        service apache2 start
        ;;
    stop)
        service apache2 stop
        ;;
    *)
        echo "Usage : svhost <sites|site>" %>2
        ;;
esac

echo "Done..."