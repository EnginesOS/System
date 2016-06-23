#!/bin/bash
src=/var/lib/docker/containers/$1/$1-json.log
dest=/var/log/engines/raw/$1-json.last
if test -f $dest
 then
 	rm $dest
 fi
echo mv $src $dest  &>>/tmp/clean.log
mv $src $dest  &>>/tmp/clean.log

#exit