#!/bin/sh


SIGNAL=$1

if test -f /run/syslogd.pid 
	then
		kill -TERM  `cat /run/syslogd.pid`
	fi
	
if test -f /run/rsyslogd.pid
then
		kill -TERM  `cat /run/rsyslogd.pid`
	fi
	
	