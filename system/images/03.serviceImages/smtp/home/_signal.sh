#!/bin/sh


echo received $1
SIGNAL=$1

PID_FILE=$2

kill -$SIGNAL `cat $PID_FILE`
rm /engines/var/run/flags/startup_complete

/home/engines/scripts/_kill_syslog.sh