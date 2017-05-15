#!/bin/bash
opts=`cat -`
#echo $opts >/tmp/set_locale
sudo  -n   /opt/engines/system/scripts/ssh/sudo/_set_locale.sh $opts