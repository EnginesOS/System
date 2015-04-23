#!/bin/sh

rm /etc/nginx/sites-enabled/http*
PID_FILE=/var/run/nginx.pid

trap trap_term  15
trap trap_hup 1
trap trap_quit 3

trap_term()
{
	if test -f $PID_FILE
	then
		kill -TERM `cat   $PID_FILE `
	fi
}
trap_hup()
{
if test -f /var/run/$PID_FILE
	then
		kill -HUP `cat   $PID_FILE `
	fi
}
trap_quit()
{
if test -f /var/run/$PID_FILE
	then
		kill -QUIT `cat   $PID_FILE `
	fi
}


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