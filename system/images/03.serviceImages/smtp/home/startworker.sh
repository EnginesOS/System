#!/bin/sh

touch   /var/log/mail.err
touch  /var/log/maillog
service busybox-syslogd start
service postfix start 

while test -f /var/lib/postfix/master.lock 
do
	  sleep 200
done


