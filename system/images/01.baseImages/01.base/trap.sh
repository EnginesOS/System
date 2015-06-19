#!/bin/sh

if test -f  /engines/var/run/flags/sig_term
	rm -f /engines/var/run/flags/sig_term
fi 

if test -f  /engines/var/run/flags/termed
	rm -f /engines/var/run/flags/termed
fi 
if test -f  /engines/var/run/flags/sig_hup
	rm -f /engines/var/run/flags/sig_hup
fi 

if test -f  /engines/var/run/flags/huped
	rm -f /engines/var/run/flags/huped
fi 
if test -f  /engines/var/run/flags/sig_quit
	rm -f /engines/var/run/flags/sig_quit
fi 

if test -f  /engines/var/run/flags/quited
	rm -f /engines/var/run/flags/quited
fi 


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
					sudo /home/_signal.sh $SIGNAL	$PID_FILE				 	
			fi
		touch /engines/var/run/flags/termed	 			
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
						sudo /home/_signal.sh $SIGNAL	$PID_FILE	

				fi
			 touch /engines/var/run/flags/huped			
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
					sudo	/home/_signal.sh $SIGNAL	$PID_FILE	
				fi				
			 	touch /engines/var/run/flags/quited
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
	 			
	

	