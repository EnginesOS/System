#!/bin/bash

/opt/engines/bin/containers_startup.sh &

if test ` docker ps -a |grep mgmt |wc -c` -eq 0
then

`cat /opt/engines/system/images/04.systemApps/mgmt/docker_cmd` 

else
 docker start mgmt
fi 


/opt/engines/bin/eservice register_consumers dns
/opt/engines/bin/eservice register_consumers nginx
