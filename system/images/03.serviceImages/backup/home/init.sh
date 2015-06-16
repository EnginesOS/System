#!/bin/sh


PID_FILE=/home/cron/fcron.pid
export PID_FILE
. /home/trap.sh


mkdir -p /engines/var/run/flags/

sudo -n syslogd  -R syslog.engines.internal:5140


/home/backup/fcron/sbin/fcron -f &
/home/backup/fcron/bin/fcrontab -u backup  -z 
touch /engines/var/run/flags/startup_complete
wait 

rm -f /engines/var/run/flags/startup_complete
