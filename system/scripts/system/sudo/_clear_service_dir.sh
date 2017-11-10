#!/bin/bash
echo clear_container_dir /opt/engines/run/services/$1 >/tmp/clear_services_dir

if test $# -eq 1
  then
  if test -d /opt/engines/run/services/$1
   then
	rm -r /opt/engines/run/services/$1 &> /tmp/clear_csd
  fi
fi 
