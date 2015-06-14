#!/bin/sh

PIDFILE=/var/spool/postfix/pid/master.pid

export PIDFILE
source /home/trap.sh

sudo /sbin/syslogd -R syslog.engines.internal:5140
sudo /usr/sbin/apache2ctl start
postmap /etc/postfix/transport 
postmap /etc/postfix/smarthost_passwd
 /usr/lib/postfix/master &
 wait $!

