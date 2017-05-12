#!/bin/sh
 touch /opt/engines/run/system/flags/engines_rebooting
 if ! test -f /etc/engines_halt_disabled
 	then
		sudo  -n /opt/engines/system/scripts/ssh/sudo/_power_off_base_os.sh  
		echo restarting
		exit 0
	fi
	
exit 127
