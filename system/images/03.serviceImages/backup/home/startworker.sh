#!/bin/sh


/etc/init.d/ssh start


cron

sleep 25

while test -f /var/run/crond.pid
do
	  sleep 120
done


