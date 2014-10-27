#!/bin/bash

cd /opt/engos/
su dockuser git pull

mv /opt/engos /opt/engines
mv /var/log/engos /var/log/engines
mv /var/lib/engos /var/lib/engines
cat ~dockuser/.profile |sed  "s/engos/engines/" |grep engines >/tmp/t
cp /tmp/t ~dockuser/.profile
chown dockuser  ~dockuser/.profile

 su -l dockuser  /opt/engines/bin/engines stop

 su -l dockuser  /opt/engines/bin/eservices stop
 
docker stop `docker ps -a |awk '{print $1}' `
 sleep 20
docker rm `docker ps -a |awk '{print $1}' `



 su -l dockuser  /opt/engines/bin/eservices create
 su -l dockuser  /opt/engines/bin/engines create
 su -l dockuser  /opt/engines/bin/containers_startup.sh 
 