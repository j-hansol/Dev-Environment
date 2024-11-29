#!/bin/bash

service php8.4-fpm start
service nginx start

exec "$@"