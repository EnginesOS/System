#!/bin/sh




if test -f /run/syslogd.pid 
	then
		pid=`cat  /run/syslogd.pid `
		kill -TERM  $pid
								
	
	fi
	

	
	