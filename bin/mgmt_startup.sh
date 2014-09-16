#!/bin/bash


if test ` docker ps -a |grep mgmt |wc -c` -eq 0
then

`cat /opt/engos/system/images/04.systemApps/mgmt/docker_cmd` 

else
 docker start mgmt
fi 
