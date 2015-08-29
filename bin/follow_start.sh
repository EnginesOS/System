#!/bin/sh

	if ! test `docker inspect -f='{{.State.Running}}' mgmt` = 'true'
 	then
	 	eservice create mgmt >/dev/null
 		eservice start mgmt >/dev/null
 	fi
 
 if ! test `docker inspect -f='{{.State.Running}}' mgmt` = 'true'
  then
  	echo "Panic failed to start mgmt "
  	exit
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
ext_ip=`curl -s http://ipecho.net/plain  `
echo please visit https://$lan_ip:10443/ or https://$ext_ip:10443/
if ! test -f ~/.has_run
	then 
		echo default user name and password admin:password
		touch ~/.has_run
	fi
	
	#echo "Please use chrome for the time being as there are problems with some java scripts in the Management Interface."