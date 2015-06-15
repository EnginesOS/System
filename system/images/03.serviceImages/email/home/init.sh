#!/bin/sh

PID_FILE=/var/spool/postfix/pid/master.pid

export PID_FILE
. /home/trap.sh
mkdir -p /engines/var/run/flags/
sudo /sbin/syslogd -R syslog.engines.internal:5140

postmap /etc/postfix/transport 
postmap /etc/postfix/smarthost_passwd
/usr/lib/postfix/master &
sudo /usr/sbin/apache2ctl  -DFOREGROUND & 
touch /engines/var/run/flags/startup_complete  
wait 

rm -f /engines/var/run/flags/startup_complete
 
 

