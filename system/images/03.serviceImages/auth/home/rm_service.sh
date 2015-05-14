#!/bin/bash


service_hash=`echo  "$*" | sed "/\*/s//STAR/g"`

. /home/engines/scripts/functions.sh

load_service_hash_to_environment

if test -z $engine
	then
		echo "Error engine not set"
		exit -1
	fi
	
if test -z $service 
	then
	echo "Error service not set"
		exit -1
	fi	

if test -z $command 
	then
	echo "Error command not set"
		exit -1
	fi
	
	 cat /home/auth/static/ssh/keys/authorized_keys		| grep -v ${service}/${command}_service.sh  >/tmp/.keys
	 mv /tmp/.keys /home/auth/static/ssh/keys/authorized_keys	
	
service_records=`grep ${service} /home/auth/static/ssh/keys/authorized_keys	`

if test `echo $service_records |wc -c ` -lt 2 
	then 		
		echo "
		drop user 'auth_$service$'@'%' ;" | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
		rm -r /home/auth/static/access/$service
	fi
#
echo "Success"
exit 0
