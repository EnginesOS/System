#!/bin/bash
if test -f /opt/engines/bin/engines/run/system/flags/first_start_complete
 then
  echo 'First Start already ran'
  exit 127
 fi
 
 
function create_service {
/opt/engines/bin/engines service $service create &>>/tmp/first_start.log
/opt/engines/bin/engines service $service wait_for start 45
/opt/engines/bin/engines service $service wait_for_startup 120
echo "$service started" &>>/tmp/first_start.log
}

function destroy_service {
/opt/engines/bin/engines service $service stop &>>/tmp/first_start.log
/opt/engines/bin/engines service $service wait_for stop 60
/opt/engines/bin/engines service $service destroy &>>/tmp/first_start.log
/opt/engines/bin/engines service $service wait_for destroy 60
echo "$service destroyed " &>>/tmp/first_start.log
}

function recreate_service {
	destroy_service
	create_service
}

function destroy_system_service {
 /opt/engines/bin/system_service.rb $service stop  >/tmp/first_start.log
 /opt/engines/bin/system_service.rb $service wait_for stop 60
 /opt/engines/bin/system_service.rb $service destroy  >/tmp/first_start.log
 /opt/engines/bin/system_service.rb $service wait_for destroy 60
echo "$service destroyed" &>>/tmp/first_start.log
}

function create_system_service {
 /opt/engines/bin/system_service.rb $service create  >/tmp/first_start.log
 /opt/engines/bin/system_service.rb $service wait_for create 60
 /opt/engines/bin/system_service.rb $service start  >/tmp/first_start.log
 /opt/engines/bin/system_service.rb $service wait_for start 120
 /opt/engines/bin/system_service.rb $service wait_for_startup 120
echo "$service recreated" &>>/tmp/first_start.log
}

function recreate_system_service {
destroy_system_service
create_system_service
}


unset CONTROL_HTTP

DOCKER_IP=`ifconfig  docker0  |grep "inet " |cut -f2 -d: |awk {'print $1}'`
export DOCKER_IP

/opt/engines/system/scripts/system/clear_service_dir.sh firstrun &>> /tmp/first_start.log

service=system
destroy_system_service


service=registry
recreate_system_service

service=system
create_system_service

sleep 30
read -p "Press enter to continue"

 for service in dns syslog cert_auth
  do
   recreate_service
 done


for services in auth mysql_server cron volmanager backup ftp nginx redis smtp ldap uadmin
 do
   create_service
 done
 
 if test -f /opt/engines/run/system/flags/install_mgmt
  then
  	/opt/engines/bin/engines service mgmt create &>>/tmp/first_start.log 
  	/opt/engines/bin/engines service mgmt wait_for start 30
  	/opt/engines/bin/engines service mgmt wait_for_startup 280 
  	echo "mgmt Started" &>>/tmp/first_start.log
  	
  	gw_ifac=`netstat -nr |grep ^0.0.0.0 | awk '{print $8}' | head -1`
  	lan_ip=`/sbin/ifconfig $gw_ifac |grep "inet addr"  |  cut -f 2 -d: |cut -f 1 -d" "`
    ext_ip=`curl -s http://ipecho.net/ |grep "Your IP is" | sed "/^.* is /s///" | sed "/<.*$/s///"`
      if ! test -n $ext_ip
       then
        ext_ip=`curl -s http://ipecho.net/ |grep "Your IP is" | sed "/^.* is /s///" | sed "/<.*$/s///"`
      fi
  	echo "Management is now at https://$lan_ip:8484/ or https://${ext_ip}:8484/"  &>>/tmp/first_start.log 
  fi
 crontab  /opt/engines/system/updates/src/etc/crontab  &>>/tmp/first_start.log 
 echo sudo su -l engines  &>>/tmp/first_start.log
 echo to use the engines management tool on the commandline &>>/tmp/first_start.log 
 touch /opt/engines//run/system/flags/first_start_complete
 echo Installation complete Ctl-c to exit & >> /tmp/first_start.log