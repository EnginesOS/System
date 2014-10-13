#!/bin/bash

/opt/engos/bin/containers_startup.sh &

if test ` docker ps -a |grep mgmt |wc -c` -eq 0
then

`cat /opt/engos/system/images/04.systemApps/mgmt/docker_cmd` 

else
 docker start mgmt
fi 

sleep 120
/opt/engos/bin/eservice register_consumers dns
/opt/engos/bin/eservice register_consumers nginx
