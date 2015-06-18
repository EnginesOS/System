#!/bin/sh

trap_term()
	{
	SIGNAL=15
	export SIGNAL
	touch /engines/var/run/flags/sig_term
		
	if test -f $PID_FILE
		then
		kill -TERM `cat   $PID_FILE `
			if test -f /home/_signal.sh
				then
					sudo /home/_signal.sh $SIGNAL					 	
			fi
		touch /engines/var/run/flags/termed	 
			 wait `cat   $PID_FILE `
		fi

	}
trap_hup()
	{
	SIGNAL=1
	export SIGNAL
	touch /engines/var/run/flags/sig_hup
	
		if test -f $PID_FILE
		kill -HUP `cat   $PID_FILE `
			then
				if test -f /home/_signal.sh
					then
						sudo /home/_signal.sh $SIGNAL		

				fi
			 touch /engines/var/run/flags/huped
			 wait `cat   $PID_FILE `
		fi
		
	}

trap_quit()
	{
	SIGNAL=15
	export SIGNAL
	touch /engines/var/run/flags/sig_quit
		if test -f $PID_FILE
			then
				kill -QUIT `cat   $PID_FILE `
				if test -f /home/_signal.sh
					then
						/home/_signal.sh $SIGNAL		
				fi
				
			 	touch /engines/var/run/flags/quited
			 	wait `cat   $PID_FILE `
		fi
	
	}
	
	trap trap_term 15 
	trap trap_hup  1
	trap trap_quit 3
	
		if test -f $PID_FILE
	 		then
	 			echo "Warning stale $PID_FILE"
	 			rm -f $PID_FILE
		fi
	 			
	

	