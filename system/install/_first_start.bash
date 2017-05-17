#!/bin/bash
if test -f /opt/engines/bin/engines/run/system/flags/first_start_complete
 then
  echo 'First Start already ran'
  exit 127
 fi
 
DOCKER_IP=`ifconfig  docker0  |grep "inet " |cut -f2 -d: |awk {'print $1}'`
export DOCKER_IP

sleep 5 
/opt/engines/bin/system_service.rb system stop  >/tmp/first_start.log
echo "System Stopped" &>>/tmp/first_start.log
/opt/engines/bin/system_service.rb registry stop &>>/tmp/first_start.log
echo "Registry Stopped" &>>/tmp/first_start.log

sleep 5
/opt/engines/bin/system_service.rb registry destroy &>>/tmp/first_start.log
echo "Registry Destroyed" &>>/tmp/first_start.log
sleep 5
/opt/engines/bin/system_service.rb registry create &>>/tmp/first_start.log
echo "Registry Created" &>>/tmp/first_start.log
sleep 5
/opt/engines/bin/system_service.rb registry start &>>/tmp/first_start.log
echo "Registry Started">>/tmp/first_start.log

sleep 10
/opt/engines/bin/system_service.rb system destroy &>>/tmp/first_start.log
echo "System Destroyed" &>>/tmp/first_start.log
sleep 25
/opt/engines/bin/system_service.rb system create &>>/tmp/first_start.log
echo "System Created" &>>/tmp/first_start.log
sleep 25
/opt/engines/bin/system_service.rb system start &>>/tmp/first_start.log
echo "System Started" &>>/tmp/first_start.log

sleep 15
/opt/engines/bin/engines service dns stop &>> /tmp/first_start.log
/opt/engines/bin/engines service dns destroy  &>>/tmp/first_start.log
/opt/engines/bin/engines service dns create &>> /tmp/first_start.log
echo "DNS Started" &>>/tmp/first_start.log

sleep 5
/opt/engines/bin/engines service syslog stop &>>/tmp/first_start.log
/opt/engines/bin/engines service syslog destroy &>> /tmp/first_start.log
/opt/engines/bin/engines service syslog create &>> /tmp/first_start.log
echo "Syslog Started" &>>/tmp/first_start.log

sleep 5
/opt/engines/bin/engines service cert_auth stop &>>/tmp/first_start.log
/opt/engines/bin/engines service cert_auth destroy& >>/tmp/first_start.log
/opt/engines/bin/engines service cert_auth create &>>/tmp/first_start.log
echo "Cert Auth Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service mysql_server create &>>/tmp/first_start.log
echo "mysql_server Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service volmanager create &>>/tmp/first_start.log
echo "volmanger Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service cron create &>>/tmp/first_start.log
echo "cron Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service auth create &>>/tmp/first_start.log
echo "auth Started" &>>/tmp/first_start.log


/opt/engines/bin/engines service backup create &>>/tmp/first_start.log
echo "backup Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service log_rotate create &>>/tmp/first_start.log
echo "log_rotate Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service ftp create &>>/tmp/first_start.log
echo "ftpd Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service nginx create &>>/tmp/first_start.log
echo "nginx Started" &>>/tmp/first_start.log

/opt/engines/bin/engines service smtp create &>>/tmp/first_start.log
echo "smtp Started" &>>/tmp/first_start.log


 if test -f /opt/engines/bin/engines/run/system/flags/install_mgmt
  then
  	/opt/engines/bin/engines service mgmt create &>>/tmp/first_start.log
  	echo "mgmt Started" &>>/tmp/first_start.log
  fi
 
 touch /opt//opt/engines/bin/engines/run/system/flags/first_start_complete