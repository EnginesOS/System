#!/bin/sh

sudo /opt/engines/scripts/_update_engines_system_software.sh

eservice stop mgmt

eservice start mgmt

/opt/engines/bin/follow_start.sh
