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
	
if test -z $pubkey 
	then
	echo "Error pubkey not set"
		exit -1
	fi	
	
if test -z $command 
	then
	echo "Error command not set"
		exit -1
	fi
	
	echo "command=\"/home/auth/scripts/${service}/${command}_service.sh\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa $pubkey auth" >>  ~/ssh/authorized_keys	

pass=test

BTICK='`'
echo "
create user ${BTICK}auth_$1${BTICK}@${BTICK}%${BTICK} identified by ${BTICK}$pass${BTICK};
GRANT SELECT,INSERT,UPDATE on auth.* to ${BTICK}auth_$1${BTICK}@${BTICK}%${BTICK};" | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname 



#
echo "Success"
exit 0
