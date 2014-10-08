#!/bin/sh


service postfix start start

while test -f /var/lib/postfix/master.lock 
do
	  sleep 200
done


