#!/bin/bash
syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf --no-caps  -v -e 

while test 0 -ne 1
do
 sleep 300
done
