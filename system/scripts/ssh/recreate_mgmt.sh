#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting

 docker stop system
 docker start system
 res=$?
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
