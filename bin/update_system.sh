#!/bin/bash
touch /opt/engines/run/system/flags/update_running

sudo  /opt/engines/scripts/_update_base_os.sh
#/opt/engines/bin/update_engines_system_software.sh

rm /opt/engines/run/system/flags/update_running
touch /opt/engines/run/system/flags/update_run

if test -f /var/run/reboot-required
 then
  touch /opt/engines/run/system/flags/reboot_required
 fi