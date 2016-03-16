#!/bin/bash
service=$1
shift
rm ~/.ssh/_${service}_keys
for key in $*
 do 
	ssh-keygen -f /opt/engines/etc/ssh/keys/services/$service/$key -N ''
	uid=`/opt/engines/scripts/get_service_uid.sh $service`
	chown /opt/engines/etc/ssh/keys/services/$service/{$key,$key.pub}
	chmod og-rwx /opt/engines/etc/ssh/keys/services/$service/$key
	pubkey=`cat /opt/engines/etc/ssh/keys/services/$service/$key.pub`
 	echo "command=\"/opt/engines/scripts/services/${key}.sh\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty  $pubkey " >>  ~/.ssh/${service}_${key}
 	done