#!/bin/sh


PID_FILE=/var/spool/postfix/pid/master.pid

export PID_FILE
. /home/trap.sh

mkdir -p /engines/var/run/flags/

sudo /sbin/syslogd -R syslog.engines.internal:5140

sudo postmap /etc/postfix/transport 
sudo /usr/lib/postfix/master &
touch  /engines/var/run/flags/startup_complete
wait  
sudo /home/engines/scripts/_kill_syslog.sh
rm /engines/var/run/flags/startup_complete
