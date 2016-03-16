#!/bin/bash
service=$1

if ! test -d  ~engines/.ssh/${service}
 then
	mkdir -p ~engines/.ssh/${service}
	chown engines ~engines/.ssh/${service}
 fi
 
shift

for key in $*
 do 
    rm /opt/engines/etc/ssh/keys/services/$service/{$key,$key.pub}
	ssh-keygen -f /opt/engines/etc/ssh/keys/services/$service/$key -N ''
	uid=`/opt/engines/scripts/get_service_uid.sh $service`
	chown $uid /opt/engines/etc/ssh/keys/services/$service/{$key,$key.pub}
	chmod og-rwx /opt/engines/etc/ssh/keys/services/$service/$key
	pubkey=`cat /opt/engines/etc/ssh/keys/services/$service/$key.pub`
 	echo "command=\"/opt/engines/scripts/services/$service/${key}.sh\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty  $pubkey " >  ~engines/.ssh/${service}/${key}_access
 	chown engines ~engines/.ssh/${service}/${key}_access
 done