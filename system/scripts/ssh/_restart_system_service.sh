#!/bin/sh
  touch /opt/engines/run/system/flags/engines_restarting
cd /tmp/
 nohup /opt/engines/bin/system_service.rb system restart
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
