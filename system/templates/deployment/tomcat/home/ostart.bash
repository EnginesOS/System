#!/bin/bash

if test ! -f  /engines/var/run/subs_run
	then
		source /home/config_functions.sh
		copy_substituted_templates >/var/log/subs.log
		touch /engines/var/run/subs_run			
	fi
	
	if test -f /engines/var/run/flags/post_install
		then
			touch /engines/var/run/post_install.done
			if test -f /home/engines/scripts/post_install.bash
				then
				/bin/bash /home/engines/scripts/post_install.bash >/var/log/post_install.log
				mv /home/engines/scripts/post_install.bash /home/engines/scripts/post_install.bash.done
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
 
if test -f /home/engines/scripts/setup.bash 
	then
		if ! test ! -f /engines/var/run/setup_complete
			then
				bash /home/engines/scripts/install.bash > /var/log/setup.log
				touch  /engines/var/run/setup_complete
		fi
	fi
	
if test -f /home/engines/scripts/pre-running.sh
	then
		bash	/home/engines/scripts/pre-running.sh
fi	

if test -n "$CRONJOBS"
then
	service cron start
fi

if test -f /home/engines/scripts/custom_start.sh
	then
		bash	/home/engines/scripts/custom_start.sh
	fi

touch /var/run/startup_complete 	
/usr/share/tomcat7/bin/catalina.sh  run
rm /engines/var/run/startup_complete
