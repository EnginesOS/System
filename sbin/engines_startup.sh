#!/bin/bash


/usr/sbin/service docker status |/usr/bin/grep running > /dev/null
if ! /usr/bin/test $? -eq 0
 then
	/usr/bin/apt-get upgrade -y linux-image-extra-$(uname -r) 
	/usr/sbin/service docker start
 fi

/bin/su  engines /opt/engines/sbin/_engines_startup.sh
