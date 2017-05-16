#!/bin/bash
if test -f /opt/engines/run/system/flags/first_start_complete
 then
  echo 'First Start already ran'
  exit 127
 fi
nohup /opt/engines/system/install/_first_start.bash &
touch /opt/engines/run/system/flags/first_start_complete
 
 
 