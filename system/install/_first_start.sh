#!/bin/bash

CONTROL_IP=`/opt/engines/bin/system_ip.sh`
export CONTROL_IP
	
DOCKER_IP=`/opt/engines/bin/docker_ip.sh`
export DOCKER_IP

if test -f /opt/engines/bin/run/system/flags/first_start_complete
 then
  echo 'First Start already ran'
  exit 127
 fi
 
 
function create_service {
echo "Create $service" 
/opt/engines/bin/engines service $service create  > /dev/null
/opt/engines/bin/engines service $service wait_for start 45 > /dev/null
/opt/engines/bin/engines service $service wait_for_startup 120 > /dev/null
/opt/engines/bin/engines service $service wait_for_startup 120 > /dev/null
echo "$service started" 
}

function destroy_service {
echo "Destroy $service" 
/opt/engines/bin/engines service $service stop  > /dev/null
/opt/engines/bin/engines service $service wait_for stop 120 > /dev/null

/opt/engines/bin/engines service $service destroy  > /dev/null
/opt/engines/bin/engines service $service wait_for destroy 60 > /dev/null
 #echo -n "Service $service is " 
#/opt/engines/bin/engines service $service state
echo "$service destroyed " 
}

function recreate_service {
	destroy_service
	create_service
}

function destroy_system_service {
echo "Destroy $service" 
 /opt/engines/bin/system_service.rb $service stop   > /dev/null
 /opt/engines/bin/system_service.rb $service wait_for stop 60 > /dev/null
# echo -n "Service $service is " 
# /opt/engines/bin/system_service.rb $service state
 /opt/engines/bin/system_service.rb $service destroy   > /dev/null
 /opt/engines/bin/system_service.rb $service wait_for destroy 60 > /dev/null
# echo -n "Service $service is " 
# /opt/engines/bin/system_service.rb $service state
echo "$service destroyed" 
}

function create_system_service {
echo "Create $service" 
 /opt/engines/bin/system_service.rb $service create  > /dev/null
 /opt/engines/bin/system_service.rb $service wait_for create 60 > /dev/null
 /opt/engines/bin/system_service.rb $service start  > /dev/null
 /opt/engines/bin/system_service.rb $service wait_for start 120 > /dev/null
 /opt/engines/bin/system_service.rb $service wait_for_startup 120 > /dev/null
echo "$service created" 
}

function recreate_system_service {
destroy_system_service
create_system_service
}


unset CONTROL_HTTP

DOCKER_IP=`ifconfig  docker0  |grep "inet " |cut -f2 -d: |awk {'print $1}'`
export DOCKER_IP

/opt/engines/system/scripts/system/clear_service_dir.sh firstrun 

service=system
destroy_system_service


service=registry
recreate_system_service

service=system
create_system_service

#Force pick up of cert
docker stop system
docker start system


/opt/engines/bin/system_service.rb system wait_for_startup 120 > /dev/null
 sleep 45
 for service in dns syslog certs
  do
   recreate_service
 done

# Wap left to last after mgmt

for service in auth mysqld cron volmgr backup ldap ftp redis smtp uadmin logrotate control
 do
   create_service
 done
 
 if test -f /opt/engines/run/system/flags/install_mgmt
  then
  	/opt/engines/bin/engines service control create  > /dev/null
  	/opt/engines/bin/engines service control wait_for start 30 > /dev/null
  	/opt/engines/bin/engines service control wait_for_startup 280  > /dev/null
  	echo "control Started" 
  	
  	gw_ifac=`netstat -nr |grep ^0.0.0.0 | awk '{print $8}' | head -1`
  	lan_ip=`/sbin/ifconfig $gw_ifac |grep "inet "  |  awk '{print $2}'`
    ext_ip=`curl -s http://ipecho.net/ |grep "Your IP is" | sed "/^.* is /s///" | sed "/<.*$/s///"`
      if ! test -n $ext_ip
       then
        ext_ip=`curl -s http://ipecho.net/ |grep "Your IP is" | sed "/^.* is /s///" | sed "/<.*$/s///"`
      fi
  	echo "Management is now at https://$lan_ip:8484/ or https://${ext_ip}:8484/"  
  fi
  
#Start Wap last, as when port 80 is open it means system and mgmt is up
service=wap
create_service
  
 crontab  /opt/engines/system/updates/src/etc/crontab  
 echo sudo su -l engines  
 echo to use the engines management tool on the commandline 
 touch /opt/engines//run/system/flags/first_start_complete
 echo Installation complete  