#!/bin/sh



if test -f /run/syslogd.pid 
	then
		kill -TERM `cat /run/syslogd.pid`
	fi
	
	rm -f /engines/var/run/flags/startup_complete