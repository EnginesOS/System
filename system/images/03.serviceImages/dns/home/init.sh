#!/bin/sh


mkdir -p /var/run/named
chown bind /var/run/named
mkdir -p /var/log/named
chown bind /var/log/named

/usr/sbin/named -c /etc/bind/named.conf -u bind 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30

while test -f /var/run/named/named.pid
	do
	  sleep 200
	done


