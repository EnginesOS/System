#!/bin/bash
echo clear_container_dir /opt/engines/run/apps/$1 >/tmp/cler_container_dir

if test $# -eq 1
  then
  if test -d /opt/engines/run/apps/$1
   then
	rm -r /opt/engines/run/apps/$1 &> /tmp/clear_csd
  fi
fi 
