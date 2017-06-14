#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting

 /opt/engines/bin/system_service.rb system stop
 /opt/engines/bin/system_service.rb system wait_for stop 10
 /opt/engines/bin/system_service.rb system destroy
 /opt/engines/bin/system_service.rb system wait_for destroy 10

  
  /opt/engines/bin/system_service.rb system create
  /opt/engines/bin/system_service.rb system wait_for create 20
  /opt/engines/bin/system_service.rb system start
  /opt/engines/bin/system_service.rb system wait_for start 30
res=`/opt/engines/bin/system_service.rb system wait_for_startup 45`
 if test $res = 'false'
  then
   res = 127
  else
   res 0
  fi
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
