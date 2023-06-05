#!/bin/bash

/opt/solr/bin/solr start -Djava.library.path=/usr/local/lib

exec "$@"