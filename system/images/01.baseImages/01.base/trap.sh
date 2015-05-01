#!/bin/sh

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
if test -f $PID_FILE
	then
		kill -HUP `cat   $PID_FILE `
	fi
}
trap_quit()
{
if test -f $PID_FILE
	then
		kill -QUIT `cat   $PID_FILE `
	fi
}