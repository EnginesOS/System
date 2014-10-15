#!/bin/sh

/etc/init.d/nginx start
touch /var/run/startup_complete
chown 21000 /var/run/startup_complete
sleep 30
while test -f /var/run/nginx.pid
do

	  sleep 200
done


