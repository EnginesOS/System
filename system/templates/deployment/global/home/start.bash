#!/bin/bash

function wait_for_debug {
if ! test -z "$Engines_Debug_Run"
 then
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
  
if test -f "$VOLDIR/.dynamic_persistence"
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
if test -f /engines/var/lang
	then
		LANG=`head -1 /engines/var/lang`
		export LC_ALL=$LANG
		export LANG
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

#Apache based 

if test -f /usr/sbin/apache2ctl
 then

	PID_FILE=/run/apache2/apache2.pid
	export PID_FILE
	. /home/trap.sh

	mkdir -p /var/log/apache2/ >/dev/null

	if test -f /home/engines/scripts/blocking.sh 
		then
		/etc/init.d/apache2 start
			 /home/engines/scripts/blocking.sh  &
			 echo  " $!" >> /run/apache2/apache2.pid
	else		
		/usr/sbin/apache2ctl -DFOREGROUND &
	fi
else
	PID_FILE=/var/run/nginx.pid
	mkdir /var/log/nginx
	
	export PID_FILE
	. /home/trap.sh
	cp /home/ruby_env /home/.env_vars
 		for env_name in `cat /home/app.env `
  			do
   				if ! test -z  "${!env_name}"
        			then
  	      				echo  "passenger_env_var $env_name  ${!env_name};"   >> /home/.env_vars
  	    		fi
  		done
	echo " passenger_env_var RAILS_ENV $RAILS_ENV;" >> /home/.env_vars
	echo " passenger_env_var SECRET_KEY_BASE $SECRET_KEY_BASE;" >> /home/.env_vars
if test -f /home/engines/scripts/blocking.sh 
		then
		nginx &
			 /home/engines/scripts/blocking.sh  &
			 echo  " $!" >> /run/apache2/apache2.pid
	else		
		nginx &
	fi
fi

if test -f /home/engines/scripts/blocking.sh
	then
		 /home/engines/scripts/blocking.sh &
		 blocking_pid=$!
		 echo " $blocking_pid " >>  $PID_FILE
	fi
		
touch /engines/var/run/flags/startup_complete
 wait 
 wait_for_debug
rm /engines/var/run/flags/startup_complete
