#!/bin/sh
touch /opt/engines/run/system/flags/update_engines_running 

ts=`date +%d-%m-%Y-%H:%M`
touch /var/log/engines/engines_system_update_$ts.log

echo "Restarting"
sleep 5

#/opt/engines/bin/eservice stop mgmt >> /var/log/engines/engines_system_update_$ts.log 
docker stop mgmt >> /var/log/engines/engines_system_update_$ts.log 

sudo /opt/engines/scripts/_update_engines_system_software.sh >> /var/log/engines/engines_system_update_$ts.log

if test -f /opt/engines/system/updates/to_run/pre_start.sh
 then
  /opt/engines/system/updates/to_run/pre_start.sh >> /var/log/engines/engines_system_update_$ts.log
  sudo /opt/engines/scripts/_mv_update_script $?
 fi

docker stop registry >> /var/log/engines/engines_system_update_$ts.log
docker start registry >> /var/log/engines/engines_system_update_$ts.log
sleep 15

/opt/engines/bin/eservice start mgmt >> /var/log/engines/engines_system_update_$ts.log
docker start mgmt >> /var/log/engines/engines_system_update_$ts.log
 
 /opt/engines/system/updates/scripts/current_update_specifics.sh
 
touch /opt/engines/run/system/flags/update_engines_run
rm /opt/engines/run/system/flags/update_engines_running

#/opt/engines/bin/follow_start.sh
