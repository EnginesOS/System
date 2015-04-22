#!/bin/sh




/etc/init.d/mysql start

mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30

while test -f /var/run/mysqld/mysqld.pid
do
	  sleep 20
done


rm /engines/var/run/startup_complete