#!/bin/sh
mv /var/lib/docker/containers/$1/$1-json.log /var/log/engines/raw/$1-json.last

#exit