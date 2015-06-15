#!/bin/sh

trap_term()
	{
	SIGNAL=15
	export SIGNAL
		
		if test -f $PID_FILE
		then
			if test -f /home/signal.sh
				then
					/home/signal.sh
				else
					kill -TERM `cat   $PID_FILE `
			fi
			 touch /engines/var/run/flags/termed
			 wait `cat   $PID_FILE `
		fi

	}
trap_hup()
	{
	SIGNAL=1
	export SIGNAL
	
		if test -f $PID_FILE
			then
				if test -f /home/signal.sh
					then
						/home/signal.sh
					else
						kill -HUP `cat   $PID_FILE `
				fi
			 touch /engines/var/run/flags/huped
			 wait `cat   $PID_FILE `
		fi
		
	}

trap_quit()
	{
	SIGNAL=15
	export SIGNAL
		if test -f $PID_FILE
			then
				
				if test -f /home/signal.sh
					then
						/home/signal.sh
					else
						kill -QUIT `cat   $PID_FILE `
				fi
				
			 	touch /engines/var/run/flags/quited
			 	wait `cat   $PID_FILE `
		fi
	
	}
	

	
			if test -f $PID_FILE
	 			then
	 				echo "Warning stale $PID_FILE"
	 				rm -f $PID_FILE
			fi
	 			
		trap trap_term 15 
		trap trap_hup  1
		trap trap_quit 3

	