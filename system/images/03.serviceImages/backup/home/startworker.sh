#!/bin/sh

#temp while debugging
/etc/init.d/ssh start
cron


while test -f /var/run/cron.pid
do
	  sleep 120
done


