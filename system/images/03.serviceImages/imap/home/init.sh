#!/bin/sh

PID_FILE=/var/run/dovecot/master.pid
export PID_FILE
. /home/trap.sh


mkdir -p /engines/var/run/flags


sudo syslogd  -R syslog.engines.internal:5140

/usr/sbin/dovecot
touch  /engines/var/run/flags/startup_complete
wait
rm /engines/var/run/flags/startup_complete