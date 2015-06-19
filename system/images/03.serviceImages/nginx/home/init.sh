#!/bin/sh

rm /etc/nginx/sites-enabled/http*
PID_FILE=/var/run/nginx.pid
export PID_FILE
. /home/trap.sh


mkdir -p /engines/var/run/flags/

/usr/sbin/nginx


touch  /engines/var/run/flags/startup_complete

while test -f $PID_FILE
	do
		sleep 600 &
		wait
	done

rm /engines/var/run/flags/startup_complete