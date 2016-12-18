#!/bin/sh
touch /opt/engines/run/system/flags/update_engines_running 

sudo -n /opt/engines/system/scripts/update/sudo/_update_engines_system_software.sh 

echo "Stopping"

docker stop system 
docker stop registry

  /opt/engines/system/scripts/system/rotate_system_log.sh 

echo "Restarting"

docker start registry 
count=0
sleep 5
  while ! test -f /opt/engines/run/system_services/registry/run/flags/startup_complete
  do 
  	sleep 5
  	count=`expr $count + 5`
  		if test $count -gt 120
  		 then
  		  echo "ERROR failed to start registry "
  		  exit
  		fi
  done 
#rm /tmp/clean.log



docker start system 
    while ! test -f /opt/engines/run/system_services/system/run/flags/startup_complete
  do 
  	sleep 5
  	count=`expr $count + 5`
  		if test $count -gt 120
  		 then
  		  echo "ERROR failed to start system "
  		  exit
  		fi
  done 
touch /opt/engines/run/system/flags/update_engines_run
rm /opt/engines/run/system/flags/update_engines_running
rm /opt/engines/run/system/flags/update_pending

