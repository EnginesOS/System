#!/bin/sh

PID_FILE=/var/run/dovecot/master.pid

source /home/trap.sh


mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

/usr/sbin/dovecot

syslogd -n -R syslog.engines.internal:5140


rm /engines/var/run/startup_complete