#!/bin/sh

sudo /opt/engines/scripts/update_engines_system_software.sh

eservice stop mgmt
eservice start mgmt
/opt/engines/follow_start.sh
