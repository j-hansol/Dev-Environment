#!/bin/bash

/usr/bin/sphp "$PHP"
/usr/bin/svhost "$CONF" "$DOCUMENT_ROOT"
if [ -f "/usr/lib/php/custom/${CUSTOM_INI}" ]; then
    ln -s "/usr/lib/php/custom/${CUSTOM_INI}" "/etc/php/${PHP}/apache2/conf.d/35-${CUSTOM_INI}"
    ln -S "/usr/lib/php/custom/${CUSTOM_INI}" "/etc/php/${PHP}/apache2/conf.d/35-${CUSTOM_INI}"
    ln -s "/usr/lib/php/custom/${CUSTOM_INI}" "/etc/php/${PHP}/cli/conf.d/35-${CUSTOM_INI}"
    ln -S "/usr/lib/php/custom/${CUSTOM_INI}" "/etc/php/${PHP}/cli/conf.d/35-${CUSTOM_INI}"
fi
exec "$@"