#!/bin/sh


PID+FILE=/home/cron/fcron.pid
export PID_FILE
source /home/trap.sh

/home/cron/sbin/fcron -p  /home/cron/log/cron.log

touch /engines/var/run/startup_complete

sudo syslogd  -R syslog.engines.internal:5140
/home/cron/sbin/fcron -f -p  /home/cron/log/cron.log  &
wait $!

rm -f /engines/var/run/startup_complete
