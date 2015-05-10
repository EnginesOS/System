#!/bin/sh


sudo /sbin/syslogd -R syslog.engines.internal:5140

postmap /etc/postfix/transport 
exec sudo /usr/lib/postfix/master

