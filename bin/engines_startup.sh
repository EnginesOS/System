#!/bin/bash

if test -f  /opt/engines/.complete_install
then
   /opt/engines/installers/complete_install.sh
else
	/opt/engines/bin/containers_startup.sh &

	if test ` docker ps -a |grep mgmt |wc -c` -eq 0
		then

			eservice create mgmt

	else
 			eservice start mgmt
	fi
fi 



