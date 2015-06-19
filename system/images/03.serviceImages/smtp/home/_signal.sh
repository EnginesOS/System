#!/bin/sh


echo received $1
SIGNAL=$1


kill -$SIGNAL `cat $PID_FILE`
rm /engines/var/run/flags/startup_complete

if test -f /run/syslogd.pid 
	then
		kill -$SIGNAL `cat /run/syslogd.pid`
	fi

	