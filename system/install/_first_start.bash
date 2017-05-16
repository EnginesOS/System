#!/bin/bash
if test -f /opt/engines/run/system/flags/first_start_complete
 then
  echo 'First Start already ran'
  exit 127
 fi
  
system_service.rb system stop  >/tmp/first_start.log
system_service.rb registry stop &>>/tmp/first_start.log
sleep 5
system_service.rb registry destroy &>>/tmp/first_start.log
sleep 5
system_service.rb registry create &>>/tmp/first_start.log
sleep 5
system_service.rb registry start &>>/tmp/first_start.log
echo "Registry Started">>/tmp/first_start.log
sleep 10
system_service.rb system destroy &>>/tmp/first_start.log
sleep 15
system_service.rb system create >>/tmp/first_start.log
sleep 15
system_service.rb system start &>>/tmp/first_start.log
echo "System Started" &>>/tmp/first_start.log
sleep 15
engines service dns stop &>> /tmp/first_start.log
engines service dns destroy  &>>/tmp/first_start.log
engines service dns create &>> /tmp/first_start.log
sleep 5
engines service syslog stop &>>/tmp/first_start.log
engines service syslog destroy &>> /tmp/first_start.log
engines service syslog create &>> /tmp/first_start.log
sleep 5
engines service cert_auth stop &>>/tmp/first_start.log
engines service cert_auth destroy& >>/tmp/first_start.log
engines service cert_auth create &>>/tmp/first_start.log
engines service auth stop &>>/tmp/first_start.log
engines service auth destroy &>>/tmp/first_start.log
engines service auth create &>>/tmp/first_start.log
engines service cron create &>>/tmp/first_start.log
engines service mysql_server create &>>/tmp/first_start.log
engines service backup create &>>/tmp/first_start.log
engines service log_rotate create &>>/tmp/first_start.log
engines service ftp create &>>/tmp/first_start.log
engines service backup create &>>/tmp/first_start.log
engines service nginx create &>>/tmp/first_start.log
engines service smtp create &>>/tmp/first_start.log

 if test -f /opt/engines/run/system/flags/install_mgmt
  then
  	engines service mgmt create
  fi
 
 