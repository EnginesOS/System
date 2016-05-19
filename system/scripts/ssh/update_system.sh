#!/bin/bash
touch /opt/engines/run/system/flags/update_running

sudo  -n /opt/engines/system/scripts/ssh/sudo/_update_base_os.sh


rm /opt/engines/run/system/flags/update_running
touch /opt/engines/run/system/flags/update_run

if test -f /var/run/reboot-required
 then
  touch /opt/engines/run/system/flags/reboot_required
 fi