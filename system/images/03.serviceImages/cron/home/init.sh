#!/bin/sh


PIDFILE=/home/cron/fcron.pid
export PIDFILE
source /home/trap.sh

/home/cron/sbin/fcron -p  /home/cron/log/cron.log

touch /engines/var/run/startup_complete

sudo syslogd -n -R syslog.engines.internal:5140

wait $!

rm -f /engines/var/run/startup_complete
