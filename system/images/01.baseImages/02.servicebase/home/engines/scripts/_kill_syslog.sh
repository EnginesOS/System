#!/bin/sh




if test -f /run/syslogd.pid 
	then
		kill -TERM  `cat /run/syslogd.pid`  1&>/dev/null
	fi
	
if test -f /run/rsyslogd.pid
then
		kill -TERM  `cat /run/rsyslogd.pid`  1&>/dev/null
	fi
	
	