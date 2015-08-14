#!/bin/sh


ts=`date +%d-%m-%Y-%H:%M`
sudo /opt/engines/scripts/_update_engines_system_software.sh >> /var/log/engines/engines_system_update_$ts.log

echo "Restarting"
sleep 5

touch /opt/engines/run/system/flags/update_engines_running
/opt/engines/bin/eservice stop mgmt

docker stop registry
docker start registry
sleep 15

/opt/engines/bin/eservice start mgmt

touch /opt/engines/run/system/flags/update_engines_run
rm /opt/engines/run/system/flags/update_engines_running

/opt/engines/bin/follow_start.sh
