#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting

 /opt/engines/bin/system_service.rb system stop
 /opt/engines/bin/system_service.rb system destroy
 sleep 6 #kludge need wait for
  /opt/engines/system/scripts/ssh/rotate_container_log.sh system
  /opt/engines/bin/system_service.rb system create

 res=$?
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
