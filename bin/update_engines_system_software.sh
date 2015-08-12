#!/bin/sh

date >> /var/log/engines/engines_system_updates.log

sudo /opt/engines/scripts/_update_engines_system_software.sh >> /var/log/engines/engines_system_updates.log

/opt/engines/bin/eservice stop mgmt

/opt/engines/eservice start mgmt

touch /opt/engines/run/system/flags/update_engines_run

/opt/engines/bin/follow_start.sh
