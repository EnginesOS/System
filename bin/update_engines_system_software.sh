#!/bin/sh
ts=`date +%d-%m-%Y-%H:%M`
touch /var/log/engines/updates/engines_system_update_$ts.log
nohup /opt/engines/bin/run_update_engines_system_software.sh  >> /var/log/engines/updates/engines_system_update_$ts.log

