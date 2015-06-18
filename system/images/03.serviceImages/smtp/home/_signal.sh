#!/bin/sh

kill -$SIGNAL `cat $PID_FILE`
rm /engines/var/run/flags/startup_complete

if test -f /run/syslogd.pid -a $SIGNAL -ne 1
	then
		kill -TERM `cat /run/syslogd.pid`
	fi
	
touch	/engines/var/run/flags/exited
	