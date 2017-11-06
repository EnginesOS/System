#!/bin/bash
echo Shutting Down Engines
/usr/bin/docker stop -t 120 `/usr/bin/docker ps |awk '{print $1}' |grep -v CONTAI `

touch /opt/engines/run/system/flags/system_shutdown
cp /opt/engines/run/system/flags/{system_started,system_started.last}
rm /opt/engines/run/system/flags/system_started