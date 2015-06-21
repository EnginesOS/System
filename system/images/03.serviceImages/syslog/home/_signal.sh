#!/bin/sh

echo received $1
SIGNAL=$1
PID_FILE=$2
kill -$SIGNAL `cat $PID_FILE`

	
 if test -f $PID_FILE
 	then
 	pid=`cat $PID_FILE`
 		if test `echo $pid | wc -c ` -gt 0
 			then
				wait $pid
			fi
	fi
/home/engines/scripts/_kill_syslog.sh