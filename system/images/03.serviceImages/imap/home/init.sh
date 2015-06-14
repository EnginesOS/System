#!/bin/sh

PID_FILE=/var/run/dovecot/master.pid
export PID_FILE
source /home/trap.sh


mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete


/usr/sbin/dovecot

sudo syslogd -n -R syslog.engines.internal:5140


rm /engines/var/run/startup_complete