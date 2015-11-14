#!/bin/sh

 docker exec dns /home/actionators/refresh_hosted_domains.sh :ip_type=lan:ip=$1:
 
su engines -c /opt/engines/bin/get_ip.sh

su engines -l /opt/engines/scripts/restart_avahi.sh
