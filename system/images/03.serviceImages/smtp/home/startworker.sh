#!/bin/sh

touch   /var/log/mail.err
touch  /var/log/maillog
service busybox-syslogd start
service postfix start 
touch /var/run/startup_complete
chown 21000 /var/run/startup_complete
sleep 30
while test -f /var/lib/postfix/master.lock 
do
	  sleep 200
done


