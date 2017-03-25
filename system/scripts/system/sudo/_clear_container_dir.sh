#!/bin/bash

if test $# -eq 1
  then
  if test -d /opt/engines/run/containers/$1
   then
	rm -r /opt/engines/run/containers/$1 &> /tmp/clear_csd
	#chown engines.containers /opt/engines/run/containers/$1
  fi
fi 
