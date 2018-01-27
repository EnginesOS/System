#!/bin/bash

if ! test -d /var/lib/engines/services/certs/store/live
 then
  mkdir /var/lib/engines/services/certs/store/live
fi

if ! test -d /var/lib/engines/services/certs/generated
 then
	cp -rp /var/lib/engines/services/certs/store/* /var/lib/engines/services/certs/store/live
	cp -rp /var/lib/engines/services/certs/store/public /var/lib/engines/services/certs/generated	
	chown 22022 /var/lib/engines/services/certs/store/live /var/lib/engines/services/certs/generated
fi	
	