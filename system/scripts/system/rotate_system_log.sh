#!/bin/sh
echo sudo  -n /opt/engines/system/scripts/system/sudo/_rotate_system_log.sh $1  &>>/tmp/clean.log
sudo  -n /opt/engines/system/scripts/system/sudo/_rotate_system_log.sh 
