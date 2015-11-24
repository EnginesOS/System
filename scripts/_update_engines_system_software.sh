#!/bin/bash
touch /opt/engines/run/system/flags/update_engines_running 
chown engines /opt/engines/run/system/flags/update_engines_running 
cd /opt/engines
git pull
return $?