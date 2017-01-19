#!/bin/sh

if test -f /opt/engines/run/system/flags/restart_disabled
	then
		echo "Restart From Gui Disabled"
		exit
	fi
	echo '10 secs to shutdown'
sleep 10

service engines stop
shutdown -r now