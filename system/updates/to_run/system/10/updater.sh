#!/bin/bash

cd /opt/engines/etc/ssh/keys/services/
 for service in `ls `
  do
	uid=`/opt/engines/scripts/get_service_uid.sh $service`
	chown $uid  /opt/engines/etc/ssh/keys/services/$service
done