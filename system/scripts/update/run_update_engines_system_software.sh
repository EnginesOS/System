#!/bin/sh
touch /opt/engines/run/system/flags/update_engines_running 

sudo -n /opt/engines/system/scripts/update/sudo/_update_engines_system_software.sh 

echo "Restarting"
sleep 5
docker stop system 

#if test -f /opt/engines/system/updates/to_run/pre_start.sh
# then
#  /opt/engines/system/updates/to_run/pre_start.sh 
#  sudo /opt/engines/scripts/_mv_update_script $?
# fi

docker stop registry
docker start registry 
sleep 15

docker start system 
   
touch /opt/engines/run/system/flags/update_engines_run
rm /opt/engines/run/system/flags/update_engines_running
rm /opt/engines/run/system/flags/update_pending

