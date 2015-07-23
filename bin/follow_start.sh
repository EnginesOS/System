#!/bin/sh

if ! test `docker inspect -f='{{.State.Running}}' mgmt` = 'true'
 then
 	eservice create mgmt >/dev/null
 	eservice start mgmt >/dev/null
 fi
 
docker logs -f mgmt &

pid=$!

while ! test -f /opt/engines/run/services/mgmt/run/flags/startup_complete 
 do
    sleep 5
 done
 
 kill $pid
 
 gw_ifac=`netstat -nr |grep ^0.0.0.0 | awk '{print $8}'`

lan_ip=`/sbin/ifconfig $gw_ifac |grep "inet addr"  |  cut -f 2 -d: |cut -f 1 -d" "`
ext_ip=`curl http://ipecho.net/plain`
echo please visit https://$lan_ip:10443/ or https://$ext_ip:10443/
echo default user name and password admin:password 