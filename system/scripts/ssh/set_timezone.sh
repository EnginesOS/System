#!/bin/bash
zone_name=`cat -`
sudo  -n   /opt/engines/system/scripts/ssh/sudo/_set_timezone.sh $zone_name
exit $?