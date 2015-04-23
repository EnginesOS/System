#!/bin/sh

touch   /var/log/mail.err
touch  /var/log/maillog
syslogd -R syslog.engines.internal:5140

trap "{kill -TERM `cat   /var/spool/postfix/pid/master.pid `}"


service postfix start 
postmap /etc/postfix/transport 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30
while test -f /var/spool/postfix/pid/master.pid
do
	  sleep 200
done


rm /engines/var/run/startup_complete