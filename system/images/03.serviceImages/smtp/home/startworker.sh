#!/bin/sh

touch   /var/log/mail.err
touch  /var/log/maillog
service busybox-syslogd start
service postfix start 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30
while test -f /var/lib/postfix/master.lock 
do
	  sleep 200
done


