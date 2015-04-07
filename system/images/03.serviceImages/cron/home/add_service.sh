#!/bin/bash

service_hash=$1

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
    
mkdir -p /home/entries/${parent_engine}/

echo $cron_line > /home/cron/entries/${parent_engine}/$name

/home/rebuild_crontab.sh

echo "Success"
exit 0
