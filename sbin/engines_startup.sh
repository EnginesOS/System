#!/bin/bash


service docker status |grep running > /dev/null
if ! test $? -eq 0
 then
	apt-get upgrade -y linux-image-extra-$(uname -r) 
	service docker start
 fi

su  engines /opt/engines/bin/_engines_startup.sh
