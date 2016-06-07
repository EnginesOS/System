#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting

 /opt/engines/bin/system_service.rb system stop
 /opt/engines/bin/system_service.rb system destroy
 sleep 60 #kludge need wait for
  /opt/engines/bin/system_service.rb create

 res=$?
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
