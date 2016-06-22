#!/bin/sh
touch /opt/engines/run/system/flags/update_engines_running 

sudo -n /opt/engines/system/scripts/update/sudo/_update_engines_system_software.sh 

echo "Restarting"
sleep 5
docker stop system 



docker stop registry
docker start registry 
sleep 15

system_cont_id=`grep container_id /opt/engines/run/system_services/system/running.yaml |cut -f2 -d:`

 ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_engines_system_software engines@172.17.0.1  /opt/engines/system/scripts/ssh/rotate_continer_log.sh $system_cont_id

docker start system 
   
touch /opt/engines/run/system/flags/update_engines_run
rm /opt/engines/run/system/flags/update_engines_running
rm /opt/engines/run/system/flags/update_pending

