#!/bin/sh


service ssh start


cron
touch /var/run/startup_complete
chown 21000 /var/run/startup_complete
sleep 25

while test -f /var/run/crond.pid
do
	  sleep 120
done
rm -f /engines/var/run/startup_complete

