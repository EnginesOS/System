#!/bin/sh


syslogd -R syslog.engines.internal:5140

#No need as uses exec
#PIDFILE=/var/run/ftpd.pid
#source /home/trap.sh

mkdir -p /engines/var/run/
	touch  /engines/var/run/startup_complete
	chown 21000 /engines/var/run/startup_complete	
	
exec proftpd -n


rm /engines/var/run/startup_complete