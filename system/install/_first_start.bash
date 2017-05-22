#!/bin/bash
if test -f /opt/engines/bin/engines/run/system/flags/first_start_complete
 then
  echo 'First Start already ran'
  exit 127
 fi
 
DOCKER_IP=`ifconfig  docker0  |grep "inet " |cut -f2 -d: |awk {'print $1}'`
export DOCKER_IP

/opt/engines/system/scripts/system/clear_service_dir.sh firstrun

/opt/engines/bin/system_service.rb system stop  >/tmp/first_start.log
/opt/engines/bin/system_service.rb system wait_for stop 20
echo "System Stopped" &>>/tmp/first_start.log

/opt/engines/bin/system_service.rb registry stop &>>/tmp/first_start.log
/opt/engines/bin/system_service.rb registry wait_for stop 20
echo "Registry Stopped" &>>/tmp/first_start.log


/opt/engines/bin/system_service.rb registry destroy &>>/tmp/first_start.log
/opt/engines/bin/system_service.rb registry wait_for destroy 10
echo "Registry Destroyed" &>>/tmp/first_start.log

/opt/engines/bin/system_service.rb registry create &>>/tmp/first_start.log
/opt/engines/bin/system_service.rb registry wait_for create 20
echo "Registry Created" &>>/tmp/first_start.log

/opt/engines/bin/system_service.rb registry start &>>/tmp/first_start.log
/opt/engines/bin/system_service.rb registry wait_for_startup 120
echo "Registry Started">>/tmp/first_start.log


/opt/engines/bin/system_service.rb system destroy &>>/tmp/first_start.log
/opt/engines/bin/system_service.rb system wait_for stop 12
echo "System Destroyed" &>>/tmp/first_start.log

/opt/engines/bin/system_service.rb system create &>>/tmp/first_start.log
/opt/engines/bin/system_service.rb system wait_for create 12
echo "System Created" &>>/tmp/first_start.log

/opt/engines/bin/system_service.rb system start &>>/tmp/first_start.log
/opt/engines/bin/system_service.rb system wait_for_startup 120
echo "System Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service dns stop &>> /tmp/first_start.log
/opt/engines/bin/engines service dns wait_for stop 20

/opt/engines/bin/engines service dns destroy  &>>/tmp/first_start.log
/opt/engines/bin/engines service dns wait_for destroy 10

/opt/engines/bin/engines service dns create &>> /tmp/first_start.log
/opt/engines/bin/engines service dns wait_for_startup 30
echo "DNS Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service syslog stop &>>/tmp/first_start.log
/opt/engines/bin/engines service syslog wait_for stop 20

/opt/engines/bin/engines service syslog destroy &>> /tmp/first_start.log
/opt/engines/bin/engines service syslog wait_for destroy 20

/opt/engines/bin/engines service syslog create &>> /tmp/first_start.log
/opt/engines/bin/engines service syslog  wait_for_startup 20
echo "Syslog Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service cert_auth stop &>>/tmp/first_start.log
/opt/engines/bin/engines service cert_auth wait_for stop 20

/opt/engines/bin/engines service cert_auth destroy& >>/tmp/first_start.log
/opt/engines/bin/engines service cert_auth wait_for destroy 20

/opt/engines/bin/engines service cert_auth create &>>/tmp/first_start.log
/opt/engines/bin/engines service cert_auth wait_for_startup 20
echo "Cert Auth Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service mysql_server create &>>/tmp/first_start.log
/opt/engines/bin/engines service mysql_server wait_for_startup 180
echo "mysql_server Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service volmanager create &>>/tmp/first_start.log
echo "volmanger Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service cron create &>>/tmp/first_start.log
/opt/engines/bin/engines service cron wait_for_startup 45
echo "cron Started" &>>/tmp/first_start.log


/opt/engines/bin/engines service auth create &>>/tmp/first_start.log
/opt/engines/bin/engines service auth wait_for_startup 45
echo "auth Started" &>>/tmp/first_start.log


/opt/engines/bin/engines service backup create &>>/tmp/first_start.log
/opt/engines/bin/engines service backup wait_for_startup 45
echo "backup Started" &>>/tmp/first_start.log 

/opt/engines/bin/engines service log_rotate create &>>/tmp/first_start.log
/opt/engines/bin/engines service backup wait_for_startup 20
echo "log_rotate Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service ftp create &>>/tmp/first_start.log
echo "ftpd Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service nginx create &>>/tmp/first_start.log
/opt/engines/bin/engines service nginx wait_for_startup 20
echo "nginx Started" &>>/tmp/first_start.log

echo Restart ftp
opt/engines/bin/engines service ftp restart &>>/tmp/first_start.log



/opt/engines/bin/engines service smtp create &>>/tmp/first_start.log
/opt/engines/bin/engines service smtp wait_for_startup 20
echo "smtp Started" &>>/tmp/first_start.log

/opt/engines/system/scripts/update/run_update_engines_system_software.sh &>>/tmp/first_start.log
 
 if test -f /opt/engines/run/system/flags/install_mgmt
  then
  	/opt/engines/bin/engines service mgmt create &>>/tmp/first_start.log
  	/opt/engines/bin/engines service mgmt wait_for_startup 180 
  	echo "mgmt Started" &>>/tmp/first_start.log
  	echo Management is now at https://$lan_ip:10443/ or https://${ext_ip}:10443/
  fi
 crontab  /opt/engines/system/updates/src/etc/crontab  &>>/tmp/first_start.log 
 echo sudo su -l engines  &>>/tmp/first_start.log
 echo to use the engines management tool on the commandline &>>/tmp/first_start.log 
 touch /opt/engines/bin/engines/run/system/flags/first_start_complete
 echo Installation complete Ctl-c to exit &>>/tmp/first_start.log