#!/bin/bash

	ssh-keygen -f /opt/engines/etc/ssh/keys/services/$service/$1 -N ''
	uid=`/opt/engines/scripts/get_service_uid.sh $1`
	chown /opt/engines/etc/ssh/keys/services/$service/{$1,$1.pub}
	chmod og-rwx /opt/engines/etc/ssh/keys/services/$service/$1	