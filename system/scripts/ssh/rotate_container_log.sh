#!/bin/sh
echo sudo  -n /opt/engines/system/scripts/ssh/sudo/_rotate_container_log.sh $1  &>>/tmp/clean.log
args=`cat -`
arg1=`echo $args | cut -f1 -d" "`
arg2=`echo $args | cut -f2 -d" "`
sudo  -n /opt/engines/system/scripts/ssh/sudo/_rotate_container_log.sh $arg1 $arg2
