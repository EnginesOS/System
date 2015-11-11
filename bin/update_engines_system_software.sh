#!/bin/sh

nohup /opt/engines/bin/run_update_engines_system_software.sh &

/opt/engines/bin/check_engines_system_update_status.sh
