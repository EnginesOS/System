#!/bin/bash

function wait_for_debug {
if ! test -z "$DEBUG"
echo "Stopped by Sleeping for 500 seconds to allow debuging"
  	 	sleep 500
  	 fi
 }
  	 
  if test  ! -f /engines/var/run/flags/volume_setup_complete
   then
   echo "Waiting for Volume setup to Complete "
 	while test ! -f /engines/var/run/flags/volume_setup_complete
 	  do
 	  echo  "."
 		sleep 4
 	 done
 	 echo "Volume setup to Complete "
  fi
if test -f $VOLDIR/.dynamic_persistence
  then
	if ! test -f /home/app/.dynamic_persistence_restored
	then
 		/home/engines/scripts/restore_dynamic_persistence.sh
 		 echo "Dyamic persistence restore Complete "
 	fi
 fi

if test -f /home/_init.sh
 	then
 		/home/_init.sh
 	fi

	if ! test -f /engines/var/run/flags/first_run_done
		then
			touch /engines/var/run/flags/first_run_done
	else		

		if test -f /home/engines/scripts/post_install.sh
			then 				
			echo "Has Post install"
				if ! test -f /engines/var/run/flags/post_install.done
					then
						echo "Running Post Install"
						/bin/bash /home/engines/scripts/post_install.sh 							
						touch /engines/var/run/flags/post_install.done
				fi
		fi
	fi		
	
if test -f /engines/var/run/flags/restart_required 
 then
  if test -f /engines/var/run/flags/started_once
   then
  		rm -rf /engines/var/run/flags/restart_required
  else
  	touch  /engines/var/run/flags/started_once
  fi
 fi
 

#drop for custom start as if custom start no blocking then it is pre running
if test -f /home/engines/scripts/pre-running.sh
	then
	echo "launch pre running"
		bash	/home/engines/scripts/pre-running.sh
fi	


#if not blocking continues
if test -f /home/engines/scripts/custom_start.sh
	then
	    echo "Custom start"	   
		result=`/home/engines/scripts/custom_start.sh`
		if test "$result" = "exit"
			then 
			wait_for_debug
				exit
		fi
		
	fi

#for non apache framework (or use custom start)
if test -f /home/startwebapp.sh 
	then
		/home/startwebapp.sh 
		 wait_for_debug
		exit
	fi
	

 if test $FRAMEWORK == 'meteor'
  then
  	cd /home/app
  	~/.meteor &
  	touch /engines/var/run/flags/startup_complete
  	echo $! > /run/meteor.pid
  	PID_FILE=/run/meteor.pid
  	. /home/trap.sh
  	wait 
  	 wait_for_debug
  	rm /engines/var/run/flags/startup_complete
  	exit
  fi

#Apache based below here

PID_FILE=/run/apache2/apache2.pid
export PID_FILE
. /home/trap.sh


  
if test -f /home/app/Rack.sh
	then 	 
	#sets PATH only (might not be needed)
		. /home/app/Rack.sh  
	fi


mkdir -p /var/log/apache2/ >/dev/null

	if test -f /home/engines/scripts/blocking.sh 
		then
		/etc/init.d/apache2 start
			 /home/engines/scripts/blocking.sh  &
			 echo  " $!" >> /run/apache2/apache2.pid
	else		
		/usr/sbin/apache2ctl -DFOREGROUND &
	fi	
		
touch /engines/var/run/flags/startup_complete
 wait 
  wait_for_debug
 rm /engines/var/run/flags/startup_complete
