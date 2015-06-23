#!/bin/bash

if  test ! -d /engines/var/run/flags/
then
	mkdir -p /engines/var/run/flags/
	chmod oug+w /engines/var/run/flags/
fi

	
	if test -f /engines/var/run/flags/post_install
		then
			echo "Has Post install"
			
			if test -f /home/engines/scripts/post_install.sh
				then 				
				echo "Running Post Install"
				/bin/bash /home/engines/scripts/post_install.sh 
				mv /home/engines/scripts/post_install.sh /home/engines/scripts/post_install.sh.done
				touch /engines/var/run/post_install.done
			fi		
	fi
	
  if test  ! -f /engines/var/run/volume_setup_complete
   then
   echo "Waiting for Volume setup to Complete "
 	while test ! -f /engines/var/run/volume_setup_complete
 	  do
 	  echo  "."
 		sleep 10
 	 done
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
	    touch /engines/var/run/startup_complete 
		bash	/home/engines/scripts/custom_start.sh
	fi

if test -f /home/startwebapp.sh 
	then
		/home/startwebapp.sh 
		exit
	fi
	
#Apache based below here

PID_FILE=/run/apache2/apache2.pid
export PID_FILE
. /home/trap.sh

mkdir -p  /engines/var/run/flags/
  
if test -f /home/app/Rack.sh
	then 	 
	#sets PATH only (might not be needed)
		. /home/app/Rack.sh  
	fi


mkdir -p /var/log/apache2/ >/dev/null

	if test -f /home/blocking.sh
		then
		/etc/init.d/apache2 start
			bash /home/blocking.sh &
	else		
		/usr/sbin/apache2ctl -DFOREGROUND &
	fi	
		
touch /engines/var/run/flags/startup_complete
 wait 
 rm /engines/var/run/flags/startup_complete