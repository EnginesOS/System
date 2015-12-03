#!/bin/sh

 /opt/engines/scripts/_setup_service_key_dir.sh $1
 mkdir -p /opt/engines/run/services/$1/run
chgrp containers  /opt/engines/run/services/$1/run
chmod g+w  /opt/engines/run/services/$1/run

uid=`/opt/engines/scripts/get_service_uid.sh $1`

mkdir -p /var/log/engines/services/$1
chown -R $uid /var/log/engines/services/$1
#no error
exit