#!/bin/bash

if test $# -gt 0
  then
  if test -d $1
   then
	rm -r /opt/engines/run/containers/$1/run
	chown engine.containers /opt/engines/run/containers/$1
  fi
fi 
