#!/bin/sh


PID_FILE=/home/cron/fcron.pid
export PID_FILE
. /home/trap.sh


mkdir -p /engines/var/run/flags/
touch /engines/var/run/flags/startup_complete

sudo syslogd  -R syslog.engines.internal:5140
/home/cron/sbin/fcron -f -p  /home/cron/log/cron.log &  
wait 

rm -f /engines/var/run/flags/startup_complete
