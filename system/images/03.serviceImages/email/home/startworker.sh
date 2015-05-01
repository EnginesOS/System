#!/bin/sh

PIDFILE=/var/spool/postfix/pid/master.pid
source /home/trap.sh

touch   /var/log/mail.err
touch  /var/log/maillog
postmap /etc/postfix/transport
postmap /etc/postfix/smarthost_passwd
service postfix start 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete
 /usr/sbin/apache2ctl start

syslogd -n -R syslog.engines.internal:5140



rm /engines/var/run/startup_complete