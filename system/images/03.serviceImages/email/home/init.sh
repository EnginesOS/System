#!/bin/sh


sudo /sbin/syslogd -R syslog.engines.internal:5140
/usr/sbin/apache2ctl start
postmap /etc/postfix/transport 
postmap /etc/postfix/smarthost_passwd
exec sudo /usr/lib/postfix/master

