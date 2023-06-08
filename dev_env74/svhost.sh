#!/bin/bash

case $1 in
    init)
        a2ensite sites
        service apache2 start
        ;;
    sites)
        a2dissite domains
        a2ensite sites
        service apache2 reload
        ;;
    domains)
        a2dissite sites
        a2ensite domains
        service apache2 reload
        ;;
    start)
        service apache2 start
        ;;
    stop)
        service apache2 stop
        ;;
    *)
        echo "Usage : svhost <sites|domains>" %>2
        ;;
esac

echo "Done..."