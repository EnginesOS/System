#!/bin/sh

echo received $SIGNAL

if test -f /run/syslogd.pid 
	then
		kill -$SIGNAL  `cat /run/syslogd.pid`
	fi
	
rm -f /engines/var/run/flags/startup_complete