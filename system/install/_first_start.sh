#!/bin/bash
if test -f /opt/engines/bin/engines/run/system/flags/first_start_complete
 then
  echo 'First Start already ran'
  exit 127
 fi
 
 
function create_service {
echo "Create $service" 
/opt/engines/bin/engines service $service create 
/opt/engines/bin/engines service $service wait_for start 45
/opt/engines/bin/engines service $service wait_for_startup 120
echo "$service started" 
}

function destroy_service {
echo "Destroy $service" 
/opt/engines/bin/engines service $service stop 
/opt/engines/bin/engines service $service wait_for stop 120
 echo -n "Service $service is " 
/opt/engines/bin/engines service $service state
/opt/engines/bin/engines service $service destroy 
/opt/engines/bin/engines service $service wait_for destroy 60
 echo -n "Service $service is " 
/opt/engines/bin/engines service $service state
echo "$service destroyed " 
}

function recreate_service {
	destroy_service
	create_service
}

function destroy_system_service {
echo "Destroy $service" 
 /opt/engines/bin/system_service.rb $service stop  
 /opt/engines/bin/system_service.rb $service wait_for stop 60
 echo -n "Service $service is " 
 /opt/engines/bin/system_service.rb $service state
 /opt/engines/bin/system_service.rb $service destroy  
 /opt/engines/bin/system_service.rb $service wait_for destroy 60
 echo -n "Service $service is " 
 /opt/engines/bin/system_service.rb $service state
echo "$service destroyed" 
}

function create_system_service {
echo "Create $service" 
 /opt/engines/bin/system_service.rb $service create  
 /opt/engines/bin/system_service.rb $service wait_for create 60
 /opt/engines/bin/system_service.rb $service start  
 /opt/engines/bin/system_service.rb $service wait_for start 120
 /opt/engines/bin/system_service.rb $service wait_for_startup 120
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
/opt/engines/bin/system_service.rb system wait_for_startup 120

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
  	/opt/engines/bin/engines service mgmt create 
  	/opt/engines/bin/engines service mgmt wait_for start 30
  	/opt/engines/bin/engines service mgmt wait_for_startup 280 
  	echo "mgmt Started" 
  	
  	gw_ifac=`netstat -nr |grep ^0.0.0.0 | awk '{print $8}' | head -1`
  	lan_ip=`/sbin/ifconfig $gw_ifac |grep "inet addr"  |  cut -f 2 -d: |cut -f 1 -d" "`
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
 echo Installation complete Ctl-c to exit 