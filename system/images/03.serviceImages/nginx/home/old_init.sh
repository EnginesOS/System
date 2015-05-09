#!/bin/sh

rm /etc/nginx/sites-enabled/http*
PID_FILE=/var/run/nginx.pid

 source /home/trap.sh


/usr/sbin/nginx
echo "started Nginx"
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chmod oug+rw /engines/var/run/startup_complete
echo 
sleep 30

while test -f /var/run/nginx.pid
do
	  sleep 200
done

rm /engines/var/run/startup_complete