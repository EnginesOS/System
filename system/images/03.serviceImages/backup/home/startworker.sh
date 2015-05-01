#!/bin/sh

PIDFILE=/home/cron/fcron.pid
source /home/trap.sh

/home/backup/fcron/sbin/fcron 
syslogd -n -R syslog.engines.internal:5140
touch /var/run/startup_complete
chown 21000 /var/run/startup_complete
sleep 100

while test -f /home/backup/fcron/fcron.pid
do
	  sleep 120
done
rm -f /engines/var/run/startup_complete

