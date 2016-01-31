#!/bin/bash


cd /opt/engines/etc
if test -d services
	then
		mv services services.old
	fi
git clone https://github.com/EnginesOS/ServiceDefinitions services
cd services
#git checkout `cat /opt/engines/release`

mkdir mapping
cd mapping

mkdir ManagedEngine
mkdir -p database/sql/mysql
mkdir -p database/sql/mysql
mkdir -p filesystem/local/filesystem

cd ../
to_map="cron backup avahi mongo pgsql mysql filesystem syslog"

for service in $to_map
	do
		service_def=`find providers/ -name ${service}.yaml`
		echo service_def  $service_def 
		cp $service_def mapping/ManagedEngine
    done
    
to_map="backup"

for service in $to_map
	do
		service_def=`find providers/ -name ${service}.yaml`
		echo service_def  $service_def 
		cp $service_def mapping/database/sql/mysql
		cp $service_def mapping/database/sql/pgsql
		cp $service_def mapping/filesystem/local/filesystem
    done
    
  to_map="ftp"

for service in $to_map
	do
		service_def=`find providers/ -name ${service}.yaml`
		echo service_def  $service_def 
		cp $service_def mapping/filesystem/local/filesystem
    done  
    