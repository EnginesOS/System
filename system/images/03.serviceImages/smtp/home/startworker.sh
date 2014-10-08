#!/bin/sh


service postfix start start

while test -f /var/run/postfix/postfix1.pid
do
	  sleep 200
done


