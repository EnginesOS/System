#!/bin/sh

PID_FILE=/var/run/ng-syslog.pid

source /home/trap.sh
 
syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf -p /$PID_FILE --no-caps  -v -e 


