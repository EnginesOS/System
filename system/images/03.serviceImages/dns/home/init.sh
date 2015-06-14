#!/bin/sh



PIDFILE=/var/run/named/named.pid
export PIDFILE
source /home/trap.sh

sudo /home/setup.sh

sudo syslogd  -R syslog.engines.internal:5140
sudo /usr/sbin/named  -c /etc/bind/named.conf -u bind 
wait $! 


