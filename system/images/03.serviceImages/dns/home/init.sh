#!/bin/sh



PID_FILE=/var/run/named/named.pid
export PID_FILE
. /home/trap.sh


mkdir -p /engines/var/run/flags/


sudo /home/setup.sh

sudo syslogd  -R syslog.engines.internal:5140
sudo /usr/sbin/named  -c /etc/bind/named.conf -u bind 
touch /engines/var/run/flags/startup_complete
wait  

rm /engines/var/run/flags/startup_complete
