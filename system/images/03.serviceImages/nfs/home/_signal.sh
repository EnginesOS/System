#!/bin/sh

kill -$SIGNAL `cat $PID_FILE`

if test -f /run/rpc.pid -a $SIGNAL -ne 1
	then
		kill -TERM `cat /run/rpcbind.pid`
	fi
	