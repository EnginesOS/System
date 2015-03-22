#!/bin/sh

/home/backup/fcron/sbin/fcron 

touch /var/run/startup_complete
chown 21000 /var/run/startup_complete
sleep 100

while test -f /home/backup/fcron/fcron.pid
do
	  sleep 120
done
rm -f /engines/var/run/startup_complete

