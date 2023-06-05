#!/bin/bash

case $1 in
    sites)
        a2dissite site
        a2ensite sites
        ;;
    site)
        a2dissite sites
        a2ensite site
        ;;
    *)
        echo "Usage : svhost <sites|site>" %>2
        ;;
esac

service apache2 restart
echo "Done..."