#!/bin/sh

PID_FILE=/var/run/postgresql/9.3-main.pid
source /home/trap.sh
 

 service postgresql start
 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30
while test -f /var/run/postgresql/9.3-main.pid
do
	  sleep 200
done

rm /engines/var/run/startup_complete
