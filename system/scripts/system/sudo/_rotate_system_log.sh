#!/bin/bash
ContId=`docker inspect --format='{{.Id}}' $1`
echo system container id $ContId >>/tmp/system_clean.log

src=/var/lib/docker/containers/${ContId}/${ContId}-json.log 
dest=/var/log/engines/raw/${ContId}-json.last

if test -f $dest
 then
 	rm $dest
 fi
echo mv $src $dest  &>>/tmp/system_clean.log
if test -f $src
 then
	cp $src $dest  &>>/tmp/system_clean.log
	rm $src
fi
if test -f /var/log/engines/system_services/system/system.log
 then
	mv /var/log/engines/system_services/system/system.log /var/log/engines/system_services/system/system.log.last 
fi
#exit