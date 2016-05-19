#!/bin/sh
 touch /opt/engines/run/system/flags/engines_rebooting
 if ! test -f /etc/engines_reboot_disabled
 	then
		sudo  -n /opt/engines/system/scripts/ssh/sudo/restart_system.sh  
		echo restarting
		exit
	fi
	
exit 127
