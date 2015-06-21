#!/bin/sh




if test -f /run/syslogd.pid 
	then
		kill -TERM  `cat /run/syslogd.pid`  
		wait  `cat /run/syslogd.pid` 
	fi
	

	
	