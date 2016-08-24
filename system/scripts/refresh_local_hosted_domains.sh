#!/bin/sh

 docker exec dns /home/actionators/refresh_hosted_domains.sh :ip_type=lan:ip=$1:
 
#su engines -c /opt/engines/system/scripts/get_ip.sh

if test `id -u` -eq 21000
 then
 	/opt/engines/scripts/restart_avahi.sh
 else
	su engines -l /opt/engines/scripts/restart_avahi.sh
fi