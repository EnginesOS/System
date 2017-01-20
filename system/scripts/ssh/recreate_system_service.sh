#!/bin/sh
 touch /opt/engines/run/system/flags/engines_restarting

 nohup /opt/engines/system/scripts/ssh/_recreate_system_service.sh &
