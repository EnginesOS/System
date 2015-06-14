#!/bin/sh


PID_FILE=/var/spool/postfix/pid/master.pid

export PID_FILE
source /home/trap.sh


sudo /sbin/syslogd -R syslog.engines.internal:5140

postmap /etc/postfix/transport 
 /usr/lib/postfix/master &
 wait $!
