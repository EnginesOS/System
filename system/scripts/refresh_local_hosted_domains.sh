#!/bin/sh

docker exec dns /home/engines/scripts/actionators/refresh_hosted_domains.sh lan $1
 

if test `id -u` -eq 21000
 then
 	/opt/engines/system/scripts/restart_avahi.sh
 else
	su engines -l /opt/engines/system/scripts/restart_avahi.sh
fi