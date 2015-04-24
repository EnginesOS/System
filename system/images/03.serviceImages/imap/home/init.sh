#!/bin/sh

PID_FILE=/var/run/dovecot/master.pid

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


mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

/usr/sbin/dovecot

syslogd -n -R syslog.engines.internal:5140


rm /engines/var/run/startup_complete