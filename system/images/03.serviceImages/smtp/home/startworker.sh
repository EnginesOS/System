#!/bin/sh

service busybox-syslogd start
service postfix start 

while test -f /var/lib/postfix/master.lock 
do
	  sleep 200
done


