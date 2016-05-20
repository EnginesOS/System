#!/bin/sh
touch /opt/engines/run/system/flags/update_engines_running 

sudo -n /opt/engines/system/scripts/update/sudo/_update_engines_system_software.sh 

echo "Restarting"
sleep 5
docker stop system 



docker stop registry
docker start registry 
sleep 15

docker start system 
   
touch /opt/engines/run/system/flags/update_engines_run
rm /opt/engines/run/system/flags/update_engines_running
rm /opt/engines/run/system/flags/update_pending

