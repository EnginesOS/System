#!/bin/sh
  touch /opt/engines/run/system/flags/engines_restarting
   docker restart registry
   opt/engines/bin/system_service.rb registry wait_for_start 25
nohup docker restart system
#  /opt/engines/bin/system_service.rb system restart  >/tmp/_restart_system.log
 #/opt/engines/bin/system_service.rb system wait_for stop 30
 #/opt/engines/bin/system_service.rb system start
 #/opt/engines/bin/system_service.rb system wait_for_start 25
#res=`/opt/engines/bin/system_service.rb system wait_for_startup 45`
 if test $? -ne 0
  then
   res=127
  else
   res=0
  fi

 res=$?
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
