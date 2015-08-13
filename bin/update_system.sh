#!/bin/bash


sudo  /opt/engines/scripts/_update_base_os.sh
#/opt/engines/bin/update_engines_system_software.sh

if test -f /var/run/reboot-required
 then
  touch /opt/engines/run/system/flags/reboot_required
 fi