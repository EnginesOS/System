#!/bin/sh



start mongod    

mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30

while test -f /var/run/mongodb/mongodb.pid
do
	  sleep 200
done


rm /engines/var/run/startup_complete