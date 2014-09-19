#!/bin/bash
#FIXME
rvm use ruby-2.1.1

if test `/opt/engos/bin/engines.rb service start dns |grep nocontainer |wc -c` -gt 0
then
	/opt/engos/bin/engines.rb service create dns
else
	/opt/engos/bin/engines.rb service start dns 
fi

if test `/opt/engos/bin/engines.rb service start nginx |grep nocontainer |wc -c` -gt 0
then
	/opt/engos/bin/engines.rb service create nginx
else
	/opt/engos/bin/engines.rb service start nginx 
fi


sleep 20
/opt/engos/bin/engines.rb service check_and_act all
sleep 20
/opt/engos/bin/engines.rb engine check_and_act all


