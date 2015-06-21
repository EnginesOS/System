#!/bin/sh




if test -f /run/syslogd.pid 
	then
		pid=`cat  /run/syslogd.pid `
		kill -TERM  $pid
								
			if test `echo $pid |wc -c ` -gt 0
				then
					wait $pid
			fi				
	fi
	

	
	