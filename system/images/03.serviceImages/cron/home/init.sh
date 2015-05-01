#!/bin/sh


PIDFILE=/home/cron/fcron.pid
source /home/trap.sh

/home/cron/sbin/fcron -p  /home/cron/log/cron.log

syslogd -n -R syslog.engines.internal:5140
touch /var/run/startup_complete
chown 21000 /var/run/startup_complete
sleep 100

while test -f /home/cron/fcron.pid
do
	  sleep 120
done
rm -f /engines/var/run/startup_complete
