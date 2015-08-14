#!/bin/sh

if test -f /opt/engines/run/system/flags/restart_disabled
	then
		echo "Restart From Gui Disabled"
		exit
	fi
	
sleep 30

docker stop `docker ps |awk '{print $1}'` 
shutdown -r now