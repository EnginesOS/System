#!/bin/sh


fcron
touch /var/run/startup_complete
chown 21000 /var/run/startup_complete
sleep 2500

while test -f /home/backup/fcron/fcrond.pid
do
	  sleep 120
done
rm -f /engines/var/run/startup_complete

