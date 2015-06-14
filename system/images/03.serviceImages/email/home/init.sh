#!/bin/sh

PID_FILE=/var/spool/postfix/pid/master.pid

export PID_FILE
source /home/trap.sh

sudo /sbin/syslogd -R syslog.engines.internal:5140
sudo /usr/sbin/apache2ctl start
postmap /etc/postfix/transport 
postmap /etc/postfix/smarthost_passwd
 /usr/lib/postfix/master &
 wait $!

