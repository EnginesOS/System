#!/bin/bash
#FIXME
#rvm use ruby-2.1.1
gw_ifac=`netstat -nr |grep ^0.0.0.0 | awk '{print $8}'`
/sbin/ifconfig $gw_ifac |grep "inet addr"  |  cut -f 2 -d: |cut -f 1 -d" " > /opt/engines/.ip
if test `/opt/engines/bin/engines.rb service start dns |grep nocontainer |wc -c` -gt 0
then
	/opt/engines/bin/engines.rb service create dns
else
	/opt/engines/bin/engines.rb service start dns 
fi

if test `/opt/engines/bin/engines.rb service start nginx |grep nocontainer |wc -c` -gt 0
then
	/opt/engines/bin/engines.rb service create nginx
else
	/opt/engines/bin/engines.rb service start nginx 
fi


sleep 20
/opt/engines/bin/engines.rb service check_and_act all
sleep 20
/opt/engines/bin/engines.rb engine check_and_act all


