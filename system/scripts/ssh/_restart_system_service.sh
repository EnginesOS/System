#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting

 /opt/engines/bin/system_service.rb system stop
 /opt/engines/bin/system_service.rb system wait_for stop 30
 /opt/engines/bin/system_service.rb system start
res=`/opt/engines/bin/system_service.rb system wait_for_startup 45`
 if test $res = 'false'
  then
   res=127
  else
   res=0
  fi

 res=$?
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
