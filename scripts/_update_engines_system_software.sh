#!/bin/bash
touch /opt/engines/run/system/flags/update_engines_running 
chown engines /opt/engines/run/system/flags/update_engines_running 
cd /opt/engines
git pull
#FIXME remove follow exit 0 after testing so result of git pull is returned
exit 0