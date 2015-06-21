#!/bin/bash

/sbin/ifconfig eth0 |grep "inet addr"  |  cut -f 2 -d: |cut -f 1 -d" " > /opt/engines/.ip 

/opt/engines/bin/containers_startup.sh &

if test ` docker ps -a |grep mgmt |wc -c` -eq 0
then

eservice create mgmt

else
 docker start mgmt
fi 



