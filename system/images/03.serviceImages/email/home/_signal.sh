#!/bin/sh

	
echo received $1
SIGNAL=$1

kill -$SIGNAL `cat /var/run/apache2/apache2.pid`

kill -$SIGNAL `cat $PID_FILE`

if test -f /run/syslogd.pid 
	then
		kill -$SIGNAL `cat /run/syslogd.pid`
	fi

	

