#!/bin/sh




if test -f /run/syslogd.pid 
	then
		kill -TERM  `cat /run/syslogd.pid`  
		if test -f /run/syslogd.pid 
			then		
				wait  `cat /run/syslogd.pid`
			fi 
	fi
	

	
	