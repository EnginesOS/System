#!/bin/sh
 touch /opt/engines/run/system/flags/engines_rebooting
 if ! test -f /etc/engines_halt_disabled
 	then
		sudo  -n /opt/engines/system/scripts/ssh/sudo/_halt_system.sh  
		echo restarting
		exit
	fi
	
exit 127
