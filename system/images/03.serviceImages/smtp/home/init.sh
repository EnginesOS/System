#!/bin/sh

touch   /var/log/mail.err
touch  /var/log/maillog
syslogd -R syslog.engines.internal:5140


PID_FILE=/var/spool/postfix/pid/master.pid

 if test -f $PID_FILE
 	then
 		echo "Warning stale $PID_FILE"
 		rm $PID_FILE
 	fi
 	
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

service postfix start 
postmap /etc/postfix/transport 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30
while test -f /var/spool/postfix/pid/master.pid
do
	  sleep 200
done


rm /engines/var/run/startup_complete