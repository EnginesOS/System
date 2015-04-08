#!/bin/bash


service_hash=`echo  "$*" | sed "/\*/s//STAR/g"`



. /home/engines/scripts/functions.sh

load_service_hash_to_environment

#FIXME make engines.internal settable

	if test -z ${cron_job}
	then
		echo Error:Missing cron_job
        exit -1
    fi
  	if test -z ${name}
	then
		echo Error:missing name
        exit -1
    fi  
    	if test -z ${parent_engine}
	then
		echo Error:missing parent_engine
        exit -1
    fi  
    
mkdir -p /home/entries/${parent_engine}/

echo $cron_line  | sed "/STAR/s//\*/g" > /home/cron/entries/${parent_engine}/$name

/home/rebuild_crontab.sh

echo "Success"
exit 0
