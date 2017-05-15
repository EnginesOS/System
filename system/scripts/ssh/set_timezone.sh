#!/bin/bash
zone_name=`cat -`
#echo  $zone_name >/tmp/set_tz
sudo  -n   /opt/engines/system/scripts/ssh/sudo/_set_timezone.sh $zone_name
exit $?