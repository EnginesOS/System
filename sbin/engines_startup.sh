#!/bin/bash

touch /opt/engines/run/system/flags/system_starting
cp /opt/engines/run/system/flags/{system_shutdown,system_shutdown.last}
rm /opt/engines/run/system/flags/system_shutdown

export DEBIAN_FRONTEND=noninteractive

/usr/sbin/service docker status |/bin/grep running > /dev/null
if ! /usr/bin/test $? -eq 0
 then
	/usr/bin/apt-get  -y  upgrade linux-image-extra-$(uname -r) 
	/usr/sbin/service docker start
 fi

/bin/su  engines /opt/engines/sbin/_engines_startup.sh


touch /opt/engines/run/system/flags/system_started