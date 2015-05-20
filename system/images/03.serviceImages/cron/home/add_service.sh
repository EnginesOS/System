#!/bin/bash


service_hash=`echo  "$*" | sed "/\*/s//STAR/g"`

. /home/engines/scripts/functions.sh

load_service_hash_to_environment

#FIXME make engines.internal settable

	if test -z "${cron_job}"
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
    
mkdir -p /home/cron/entries/${parent_engine}/

mins=`echo $cron_job | cut -d' ' -f1`
hrs=`echo $cron_job | cut -d' ' -f2`
day=`echo $cron_job | cut -d' ' -f3`
dow=`echo $cron_job | cut -d' ' -f4`
dom=`echo $cron_job | cut -d' ' -f5`
cmd=`echo $cron_job | cut -d' ' -f 6- `

echo $mins $hrs $day $dow $dom docker exec ${parent_engine} $cmd  | sed "/STAR/s//\*/g" > /home/cron/entries/${parent_engine}/$name

/home/rebuild_crontab.sh

echo "Success"
exit 0
