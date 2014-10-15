#!/bin/sh
/usr/sbin/named -c /etc/bind/named.conf -u bind -g

touch /var/run/startup_complete
chown 21000 /var/run/startup_complete

sleep 30
while test -f /var/run/named.pid
	do
	  sleep 200
	done


