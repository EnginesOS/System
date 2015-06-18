#!/bin/sh

kill -$SIGNAL `cat /var/run/apache2/apache2.pid`

kill -$SIGNAL `cat $PID_FILE`

if test -f /run/syslogd.pid -a $SIGNAL -ne 1
	then
		kill -TERM `cat /run/syslogd.pid`
	fi
	rm /engines/var/run/flags/startup_complete