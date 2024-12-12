#!/bin/bash

/usr/bin/sphp 8.2
/usr/bin/svhost init
exec "$@"