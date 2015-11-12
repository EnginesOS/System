#!/bin/bash

mkdir -p /opt/engines/system/updates/ran/
ts=`date +%d-%m-%Y-%H:%M`

 if test $1 eq
   then 
  	mv /opt/engines/system/updates/to_run/pre_start.sh /opt/engines/system/updates/ran/pre_start.$ts
  fi