#!/bin/sh

sleep 2
touch /opt/engines/run/system/flags/engines_rebooting
touch /opt/engines/run/system/flags/engines_rebooted
if ! test -f /opt/engines/etc/engines_reboot_disabled
 then
	#sudo -n /opt/engines/system/scripts/ssh/sudo/_restart_base_os.sh &
	sleep 10
	exit
else
	 /opt/engines/system/scripts/ssh/restart_system_service.sh 
	rm -f /opt/engines/run/system/flags/engines_rebooting  
	sleep 2
fi
	
exit 
