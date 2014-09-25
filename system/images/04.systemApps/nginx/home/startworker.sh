#!/bin/sh

/etc/init.d/nginx start
sleep 30
while test -f /var/run/nginx.pid
do
tail -f /var/log/nginx/error.log &

	  sleep 200
done


