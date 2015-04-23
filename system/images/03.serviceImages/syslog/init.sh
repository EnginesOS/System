#!/bin/bash
trap "{kill -TERM `cat   /var/run/ng-syslog.pid `}"
syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf -p /var/run/ng-syslog.pid--no-caps  -v -e 


