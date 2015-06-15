#!/bin/sh

trap_term()
	{
		if test -f $PID_FILE
		then
			kill -TERM `cat   $PID_FILE `
			 touch /engines/var/run/flags/termed
			 wait `cat   $PID_FILE `
		fi
		SIGNAL=15
		export SIGNAL
	}
trap_hup()
	{
	if test -f $PID_FILE
		then
			kill -HUP `cat   $PID_FILE `
			 touch /engines/var/run/flags/huped
			 wait `cat   $PID_FILE `
		fi
		SIGNAL=1
		export SIGNAL
	}

trap_quit()
	{
	if test -f $PID_FILE
		then
			kill -QUIT `cat   $PID_FILE `
			 touch /engines/var/run/flags/quited
			 wait `cat   $PID_FILE `
		fi
		SIGNAL=15
		export SIGNAL
	}
	

	
			if test -f $PID_FILE
	 			then
	 				echo "Warning stale $PID_FILE"
	 				rm $PID_FILE
			fi
	 			
		trap trap_term 15 
		trap trap_hup  1
		trap trap_quit 3

	