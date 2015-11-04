#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting
 docker stop mgmt
 docker start mgmt
 res=$?
rm	/opt/engines/run/system/flags/engines_restarting
exit $res
