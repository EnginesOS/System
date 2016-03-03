#!/bin/sh

if test -f /opt/engines/run/system/flags/restart_disabled
	then
		echo "Restart From Gui Disabled"
		exit
	fi
	echo '10 secs to shutdown'
sleep 10

docker stop `docker ps |awk '{print $1}' |grep -v CONTAI ` 
shutdown -r now