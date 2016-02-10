#/bin/bash

#if test -d /opt/engines/run/services/$1
 #then
 #	echo "$1 not configured as multi provider capable"
 #	exit
 #fi
 
#if test -h /opt/engines/run/services/$1
 #then
 #	rm /opt/engines/run/services/$1
 #fi
 rm -r /opt/engines/run/services/$1
cp -r /opt/engines/run/services-available/$1/$2 /opt/engines/run/services/$1
chgrp -R containers /opt/engines/run/services/$1
chmod g+rwx /opt/engines/run/services/$1

