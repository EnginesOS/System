#!/bin/sh




if test -f /run/syslogd.pid 
	then
		kill -TERM  `cat /run/syslogd.pid`
	fi
	
if test -f /run/rsyslogd.pid
then
		kill -TERM  `cat /run/rsyslogd.pid`
	fi
	
	