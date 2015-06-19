#!/bin/sh

rm /etc/nginx/sites-enabled/http*
PID_FILE=/var/run/nginx.pid

. /home/trap.sh


mkdir -p /engines/var/run/

/usr/sbin/nginx


touch  /engines/var/run/startup_complete

while test -f $PID_FILE
	do
		sleep 600 &
		wait
	done

rm /engines/var/run/startup_complete