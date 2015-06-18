#!/bin/sh

PID_FILE=/var/spool/postfix/pid/master.pid

export PID_FILE
. /home/trap.sh

mkdir -p /engines/var/run/flags/
sudo -n /sbin/syslogd -R syslog.engines.internal:5140

sudo -n postmap /etc/postfix/transport 
sudo -n postmap /etc/postfix/smarthost_passwd
sudo -n /usr/lib/postfix/master &
sudo -n  /usr/sbin/apache2ctl  -DFOREGROUND & 
touch /engines/var/run/flags/startup_complete  
wait 

rm -f /engines/var/run/flags/startup_complete
 
 

