#!/bin/bash
ContId=`docker inspect --format='{{.Id}}' $1`
echo system container id $ContId >>/tmp/clean.log

src=/var/lib/docker/containers/${ContId}/${ContId}-json.log 
dest=/var/log/engines/raw/${ContId}-json.last

if test -f $dest
 then
 	rm $dest
 fi
echo mv $src $dest  &>>/tmp/clean.log
mv $src $dest  &>>/tmp/clean.log
mv /var/log/engines/system_services/system/system.log /var/log/engines/system_services/system/system.log.last
#exit