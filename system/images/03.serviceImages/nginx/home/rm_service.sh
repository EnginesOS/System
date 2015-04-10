#!/bin/bash

service_hash=$1

. /home/engines/scripts/functions.sh

load_service_hash_to_environment

if test -z $fqdn
 then
 	Error:no FQDN in nginx service hash
 	exit -1
 fi
 
 if test -z $port
 then
 	Error:no port in nginx service hash
 	exit -1
 fi
  if test -z $proto
 then
 	Error:no proto in nginx service hash
 	exit -1
 fi
 
   if test -z $name
 then
 	Error:no name in nginx service hash
 	exit -1
 fi

	if test -f /etc/nginx/sites-enabled/${proto}_${fqdn}.site
	 then
	 	rm /etc/nginx/sites-enabled/${proto}_${fqdn}.site	 
	 	kill -HUP `cat /var/run/nginx.pid`
	else
		echo Error:config /etc/nginx/sites-enabled/${proto}_${fqdn}.site not found
		exit -1
	fi
	 
	 echo Success
	 