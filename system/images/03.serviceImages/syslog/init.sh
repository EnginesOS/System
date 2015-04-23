#!/bin/sh

PID_FILE=/var/run/ng-syslog.pid

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

syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf -p /$PID_FILE --no-caps  -v -e 


