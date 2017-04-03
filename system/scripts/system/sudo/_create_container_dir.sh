#!/bin/bash
echo create_container_dir /opt/engines/run/containers/$1 >/tmp/create_container_dir
if test $# -eq 1
  then
  if ! test -d /opt/engines/run/containers/$1 &>> /tmp/create_container_dir
   then
	mkdir /opt/engines/run/containers/$1 &>>  /tmp/create_container_dir
  fi
  
  chown -R engines.containers /opt/engines/run/containers/$1 &>>  /tmp/create_container_dir
fi 
