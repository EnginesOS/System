#!/bin/sh


PIDFILE=/var/spool/postfix/pid/master.pid

export PIDFILE
source /home/trap.sh


sudo /sbin/syslogd -R syslog.engines.internal:5140

postmap /etc/postfix/transport 
 /usr/lib/postfix/master &
 wait $!
