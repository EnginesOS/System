#!/bin/sh

sudo  -n /opt/engines/system/scripts/ssh/sudo/_rotate_container_log.sh $1
#mv /var/lib/docker/containers/$1/$1-json.l /var/log/engines/raw/$1-json.last