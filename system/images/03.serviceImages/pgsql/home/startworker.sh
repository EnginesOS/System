#!/bin/sh

/etc/init.d/ssh start

touch /var/run/startup_complete
chown 21000 /var/run/startup_complete
sleep 30
while test -f /var/run/postgresql/*.pid
do
	  sleep 200
done


