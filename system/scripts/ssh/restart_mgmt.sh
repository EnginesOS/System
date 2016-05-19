#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting
 #docker stop mgmt
 #docker start mgmt
 docker stop system
 docker start system
 res=$?
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
