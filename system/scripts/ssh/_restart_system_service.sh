#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting

 /opt/engines/bin/system_service.rb system stop
 /opt/engines/bin/system_service.rb system wait_for stop 10
 /opt/engines/bin/system_service.rb system start
 /opt/engines/bin/system_service.rb system wait_for_startup 45

 res=$?
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
