#!/bin/sh

echo received $1
SIGNAL=$1

kill -$SIGNAL `cat $PID_FILE`
 
if test -f /run/rpc.pid
	then
		kill -$SIGNAL `cat /run/rpcbind.pid`
	fi
	
		kill -$SIGNAL `cat /run/syslogd.pid`
	
	