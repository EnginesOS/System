#!/bin/sh
touch /opt/engines/run/system/flags/update_engines_running 

sudo -n /opt/engines/system/scripts/update/sudo/_update_engines_system_software.sh 

if test -f /opt/engines/run/system/flags/update_pending
 then
	rm /opt/engines/run/system/flags/update_pending
fi

echo "Stopping"

docker stop system 
docker stop registry
sleep 5

  /opt/engines/system/scripts/system/rotate_system_log.sh system > /tmp/_rotate_system_log.system
 /opt/engines/system/scripts/system/rotate_system_log.sh registry   > /tmp/rotate_system_log.registry
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
if test -f /opt/engines/run/system/flags/update_engines_running
 then
	rm /opt/engines/run/system/flags/update_engines_running
fi



if test $1 = '-f'
 then 
	docker logs -f system
 fi 
