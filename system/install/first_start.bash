#!/bin/bash

system_service.rb system stop
system_service.rb registry stop
system_service.rb registry destroy
system_service.rb registry create
system_service.rb system destroy
system_service.rb system create
engines service syslog create
engines service dns stop
engines service dns destroy 
engines service dns create
engines service auth stop
engines service auth destroy
engines service auth create
engines service cron create
engines service mysql_server create
engines service backup create
engines service logrotate create
engines service ftp create
engines service backup create
engines service nginx create
engines service smtp create
engines service mgmt create 
 
 