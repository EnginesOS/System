#!/bin/sh


sudo /sbin/syslogd -R syslog.engines.internal:5140


exec sudo /usr/lib/postfix/master
#service postfix start 
postmap /etc/postfix/transport 

mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chgrp containers /engines/var/run/startup_complete

sleep 30
while test -f /var/spool/postfix/pid/master.pid
do
	  sleep 200
done


rm /engines/var/run/startup_complete