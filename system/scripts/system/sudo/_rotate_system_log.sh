#!/bin/bash
system_cont_id=`grep container_id /opt/engines/run/system_services/system/running.yaml |cut -f2 -d:`
src=/var/lib/docker/containers/$system_cont_id/$system_cont_id-json.log 
dest=/var/log/engines/raw/$system_cont_id-json.last
if test -f $dest
 then
 	rm $dest
 fi
echo mv $src $dest  &>>/tmp/clean.log
mv $src $dest  &>>/tmp/clean.log

#exit