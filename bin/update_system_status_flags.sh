#!/bin/bash



if test -f /var/run/reboot_required
 then
	touch /opt/engines/run/system/flags/engines_rebooting
else
	rm -f /opt/engines/run/system/flags/engines_rebooting 
fi