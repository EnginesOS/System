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

if test -f /home/engines/scripts/custom_install.sh
	then
	echo has custom install
		if test ! -f /engines/var/run/setup_complete
			then
			echo running custom install
				bash /home/engines/scripts/custom_install.sh
				touch  /engines/var/run/setup_complete
		fi
	fi
	
if test -f /home/engines/scripts/pre-running.sh
	then
	echo "launch pre running"
		bash	/home/engines/scripts/pre-running.sh
fi	


if test -f /home/engines/scripts/custom_start.sh
	then
	    echo "Custom start"
	    touch /engines/var/run/startup_complete 
		bash	/home/engines/scripts/custom_start.sh
	fi

if test -f /home/app/Rack.sh
	then 
	
		/home/app/Rack.sh
	fi

if test -f /home/startwebapp.sh
	then
	touch /engines/var/run/startup_complete
 	/home/startwebapp.sh
 	fi

touch /engines/var/run/startup_complete
 rm -f /run/apache2/apache2.pid 

exec /usr/sbin/apache2ctl -D FOREGROUND 

 rm -f /run/apache2/apache2.pid 
 
 
 rm /engines/var/run/startup_complete