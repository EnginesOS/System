#!/bin/sh
touch /opt/engines/run/system/flags/update_engines_running 

sudo -n /opt/engines/system/scripts/update/sudo/_update_engines_system_software.sh 

if test -f /opt/engines/run/system/flags/update_pending
 then
	rm /opt/engines/run/system/flags/update_pending
fi

echo "Stopping"

docker stop system 
/opt/engines/bin/system_service.rb system wait_for stop 20
docker stop registry
/opt/engines/bin/system_service.rb registry wait_for stop 20


  /opt/engines/system/scripts/system/rotate_system_log.sh system > /tmp/_rotate_system_log.system
 /opt/engines/system/scripts/system/rotate_system_log.sh registry   > /tmp/rotate_system_log.registry
 echo "Restarting"

docker start registry 
count=0
/opt/engines/bin/system_service.rb registry wait_for start 20
/opt/engines/bin/system_service.rb registry wait_for_startup 120


docker start system 
/opt/engines/bin/system_service.rb system wait_for start 20
/opt/engines/bin/system_service.rb system wait_for_startup 120

if test -f /opt/engines/system/startup/flags/replace_keys
 then
  /opt/engines/system/scripts/startup/replace_keys.sh 
  rm /opt/engines/system/startup/flags/replace_keys 
fi

touch /opt/engines/run/system/flags/update_engines_run
if test -f /opt/engines/run/system/flags/update_engines_running
 then
	rm /opt/engines/run/system/flags/update_engines_running
fi

release=`cat /opt/engines/release`
docker pull engines/fsconfigurator:$release

if test $# -gt 0
then
	if test $1 = '-f'
 	then 
		docker logs -f system
 	fi 
fi