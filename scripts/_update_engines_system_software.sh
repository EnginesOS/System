#!/bin/bash
touch /opt/engines/run/system/flags/update_engines_running 
chown engines /opt/engines/run/system/flags/update_engines_running 
cd /opt/engines
git pull
 cp /opt/engines/system/updates/src/etc/sudoers.d/engines /etc/sudoers.d/engines 
exit $?