#!/bin/bash
#FIXME

#gw_ifac=`netstat -nr |grep ^0.0.0.0 | awk '{print $8}'`
#/sbin/ifconfig $gw_ifac |grep "inet addr"  |  cut -f 2 -d: |cut -f 1 -d" " > /opt/engines/.ip

if test `/opt/engines/bin/engines.rb service start dns |grep nocontainer |wc -c` -gt 0
then
	/opt/engines/bin/engines.rb service create dns
else
	/opt/engines/bin/engines.rb service start dns 
fi
if test `/opt/engines/bin/engines.rb service start mysql_server |grep nocontainer |wc -c` -gt 0
then
	/opt/engines/bin/engines.rb service create mysql_server
else
	/opt/engines/bin/engines.rb service start mysql_server 
fi

if test `/opt/engines/bin/engines.rb service start nginx |grep nocontainer |wc -c` -gt 0
then
	/opt/engines/bin/engines.rb service create nginx
else
	/opt/engines/bin/engines.rb service start nginx 
fi

if test `/opt/engines/bin/engines.rb service start auth |grep nocontainer |wc -c` -gt 0
then
	/opt/engines/bin/engines.rb service create auth
else
	/opt/engines/bin/engines.rb service start auth 
fi

sleep 20
/opt/engines/bin/engines.rb service check_and_act all
sleep 20
/opt/engines/bin/engines.rb engine check_and_act all


