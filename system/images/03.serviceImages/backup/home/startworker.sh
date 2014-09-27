#!/bin/sh

/etc/init.d/ssh start


while test -f /var/run/
do
	  sleep 20
done


