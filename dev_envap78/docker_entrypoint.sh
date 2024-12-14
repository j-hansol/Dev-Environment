#!/bin/bash

/usr/bin/sphp "$PHP"
/usr/bin/svhost "$CONF" "$DOCUMENT_ROOT"
exec "$@"