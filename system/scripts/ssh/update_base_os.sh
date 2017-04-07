#!/bin/bash
touch /opt/engines/run/system/flags/update_running
tsdate=`date  +%d_%m_%y_%H:%M`
sudo  -n /opt/engines/system/scripts/ssh/sudo/_update_base_os.sh &> /var/log/engines/updates/base_os_update.current

mv /var/log/engines/updates/base_os_update.current /var/log/engines/updates/base_os_update_$tsdate.log
rm /opt/engines/run/system/flags/update_running
touch /opt/engines/run/system/flags/update_run
service docker status |grep Active |grep running
if test $? -ne 0
 then
 	/opt/engines/bin/restart_docker_and_engines.sh
 fi
/opt/engines/bin/engines  containers  check_and_act
if test -f /var/run/reboot-required
 then
  touch /opt/engines/run/system/flags/reboot_required
 fi