#!/bin/sh

/etc/init.d/ssh start



while test -f /var/run/postgresql/*.pid
do
	  sleep 200
done


