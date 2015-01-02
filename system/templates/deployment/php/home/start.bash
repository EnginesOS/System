#!/bin/bash


if test ! -f  /engines/var/run/subs_run
	then
	echo "Performing substitutions"
	cd /home/
		source /home/config_functions.sh
		copy_substituted_templates
		touch /engines/var/run/subs_run
		cd /home/app			
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
 
if test -f /home/engines/scripts/install.sh 
	then
	echo has custom install
		if ! test ! -f /engines/var/run/setup_complete
			then
			echo running custom install
				bash /home/engines/scripts/install.sh 
				touch  /engines/var/run/setup_complete
		fi
	fi
	
if test -f /home/engines/scripts/pre-running.sh
	then
	echo "launch pre running"
		bash	/home/engines/scripts/pre-running.sh
fi	

if test -n "$CRONJOBS"
then
	service cron start
fi

if test -f /home/engines/scripts/start.sh
	then
	    echo "Custom start"
		bash	/home/engines/scripts/start.sh
	fi

touch /var/run/startup_complete 	
/usr/sbin/apache2ctl -D FOREGROUND 
 rm -f /run/apache2/apache2.pid 
 rm /engines/var/run/startup_complete