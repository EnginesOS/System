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

if test -f /home/engines/scripts/startwebapp.sh 
	then
		/home/engines/scripts/startwebapp.sh 
	fi
	
#Apache based below here

if test -f /run/apache2/apache2.pid 
	then
 		rm -f /run/apache2/apache2.pid
 		echo "Warning stale Apache pid file removed"
    fi 

trap "{kill -TERM `cat   /run/apache2/apache2.pid `}"  15
rm -f /run/apache2/apache2.pid 
  
if test -f /home/app/Rack.sh
	then 	 
	#sets PATH only (might not be needed)
		. /home/app/Rack.sh  
	fi

touch /engines/var/run/startup_complete
mkdir -p /var/log/apache2/

	if test -f /home/blocking.sh
		then
		/etc/init.d/apache2 start
			bash /home/blocking.sh
	else		
		/usr/sbin/apache2ctl -D FOREGROUND
	fi	
 

 
 
 rm /engines/var/run/startup_complete