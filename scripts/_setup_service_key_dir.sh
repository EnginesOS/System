#!/bin/sh

uid=`/opt/engines/scripts/get_service_uid.sh $1`
mkdir -p   /opt/engines/etc/ssh/keys/services/$1
chown $uid  /opt/engines/etc/ssh/keys/services/$1