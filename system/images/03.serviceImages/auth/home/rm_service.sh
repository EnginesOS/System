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
	
	 cat ~/ssh/authorized_keys | grep -v ${service}/${command}_service.sh  >/tmp/.keys
	 mv /tmp/.keys ~/ssh/authorized_keys
	BTICK='`'
echo "
drop user ${BTICK}auth_$1${BTICK}@${BTICK}%${BTICK} ;" | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname 
	
#
echo "Success"
exit 0
