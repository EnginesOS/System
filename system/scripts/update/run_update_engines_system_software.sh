#!/bin/sh
touch /opt/engines/run/system/flags/update_engines_running 

sudo -n /opt/engines/system/scripts/update/sudo/_update_engines_system_software.sh 

echo "Restarting"
sleep 5
docker stop mgmt 

#if test -f /opt/engines/system/updates/to_run/pre_start.sh
# then
#  /opt/engines/system/updates/to_run/pre_start.sh 
#  sudo /opt/engines/scripts/_mv_update_script $?
# fi

docker stop registry
docker start registry 
sleep 15

#/opt/engines/system/updates/scripts/current_update_specifics.sh

#/opt/engines/bin/eservice start mgmt 
docker start mgmt 
 
 
 
touch /opt/engines/run/system/flags/update_engines_run
rm /opt/engines/run/system/flags/update_engines_running
rm /opt/engines/run/system/flags/update_pending
#/opt/engines/bin/follow_start.sh
