#!/bin/bash
echo create_container_dir /opt/engines/run/apps/$1 >/tmp/create_container_dir
if test $# -eq 1
  then
  if ! test -d /opt/engines/run/apps/$1 &>> /tmp/create_container_dir
   then
	mkdir /opt/engines/run/apps/$1 &>>  /tmp/create_container_dir
  fi
   if ! test -d /opt/engines/etc/ssh/keys/containers/$1 
   then
	mkdir /opt/engines/etc/ssh/keys/containers/$1  &>>  /tmp/create_container_dir
	chown -R engines.containers /opt/engines/etc/ssh/keys/containers/$1
	chmod g+w /opt/engines/etc/ssh/keys/containers/$1
  fi
  
  chown -R engines.containers /opt/engines/run/apps/$1 &>>  /tmp/create_container_dir
fi 
