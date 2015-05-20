#!/bin/sh

uid=`grep $1 /opt/engines/etc/container_uids |awk '{print $3}'` 
chown $uid /opt/engines/ssh/keys/services/$1