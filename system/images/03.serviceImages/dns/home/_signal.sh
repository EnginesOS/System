#!/bin/sh



echo received $1
SIGNAL=$1
PID_FILE=$2

kill -$SIGNAL  `cat $PID_FILE`

if test -f /run/syslogd.pid 
	then
		kill -$SIGNAL  `cat /run/syslogd.pid`
	fi
	
