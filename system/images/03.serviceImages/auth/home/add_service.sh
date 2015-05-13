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

if ! test -f /home/auth/access/$service/access
	then
		mkdir /home/auth/access/$service/
		cp /home/get_access.sh /home/auth/access/$1/
	#FIX ME as this allows for any auth user so sneak a peak at other auth
		echo "command=\"/home/auth/access/$service/get_access.sh\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa $pubkey auth" >>  ~/ssh/authorized_keys	
		pass=test
		BTICK='`'
		echo "
			create user ${BTICK}auth_$service${BTICK}@${BTICK}%${BTICK} identified by ${BTICK}$pass${BTICK};
			GRANT SELECT,INSERT,UPDATE on auth.* to ${BTICK}auth_$service${BTICK}@${BTICK}%${BTICK};" | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname 
	
		echo ":db_username=auth_$service:db_password=$pass:database_name=auth:db_host=mysql.engines.internal:" > /home/auth/access/$service/access
	fi

#
echo "Success"
exit 0
