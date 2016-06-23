#!/bin/sh
echo sudo  -n /opt/engines/system/scripts/ssh/sudo/_rotate_container_log.sh $1  &>>/tmp/clean.log
sudo  -n /opt/engines/system/scripts/ssh/sudo/_rotate_container_log.sh $1
