#!/bin/bash



if test -f /var/run/reboot-required
 then
	touch //opt/engines/run/system/flags/reboot_required
else
	rm -f /opt/engines/run/system/flags/reboot_required
fi