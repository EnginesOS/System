#!/bin/sh

touch   /var/log/mail.err
touch  /var/log/maillog
service busybox-syslogd start
service postfix start 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete
 /usr/sbin/apache2ctl start
sleep 30
syslogd -R syslog.engines.internal:5140

while test -f /var/lib/postfix/master.lock 
do
	  sleep 200
done


rm /engines/var/run/startup_complete