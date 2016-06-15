#!/bin/sh

 /opt/engines/scripts/_setup_service_key_dir.sh $1
 mkdir -p /opt/engines/run/services/$1/run/flags
chgrp containers -R /opt/engines/run/services/$1/run
chmod g+w -R  /opt/engines/run/services/$1/run

 mkdir -p /opt/engines/run/services/$1/run/f
 

uid=`/opt/engines/system/scripts/system/get_service_uid.sh $1`

mkdir -p /var/log/engines/services/$1
chown -R $uid /var/log/engines/services/$1
chown $uid /opt/engines/run/services/$1/run/f
#no error
exit