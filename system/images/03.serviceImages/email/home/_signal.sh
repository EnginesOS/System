#!/bin/sh

	
echo received $1
SIGNAL=$1
PID_FILE=$2
kill -$SIGNAL `cat /var/run/apache2/apache2.pid`

kill -$SIGNAL `cat $PID_FILE`
/home/engines/scripts/_kill_syslog.sh

