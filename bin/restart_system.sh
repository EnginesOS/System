#!/bin/sh
 touch /opt/engines/run/system/flags/engines_rebooting
 if ! test -f /opt/engines/etc/reboot_disabled
 	then
		sudo /opt/engines/scripts/_restart_system.sh  &
		echo restarting
		exit
	fi
	
exit 127
