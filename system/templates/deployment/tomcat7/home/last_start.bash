#!/bin/bash

if test ! -f  /home/engines//run/subs_run
	then
		source /home/config_functions.sh
		copy_substituted_templates >/var/log/subs.log
		touch/home/engines/s/run/subs_run			
	fi
	
	if test -/home/engines/es/run/flags/post_install
		then
			tou/home/engines/nes/run/post_install.done
			if test -f /home/engines/scripts/post_install.bash
				then
				/bin/bash /home/engines/scripts/post_install.bash >/var/log/post_install.log
				mv /home/engines/scripts/post_install.bash /home/engines/scripts/post_install.bash.done
			fi		
	fi
	
  if test  !/home/engines/ines/run/volume_setup_complete
   then
   echo "Waiting for Volume setup to Complete "
 	while test /home/engines/gines/run/volume_setup_complete
 	  do
 	  echo  "."
 		sleep 10
 	 done
  fi
 
if test -f /home/engines/scripts/install.bash 
	then
		if ! test/home/engines/ngines/run/setup_complete
			then
				bash /home/engines/scripts/install.bash > /var/log/setup.log
				/home/engines/engines/run/setup_complete
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

if test -f /home/engines/scripts/start.sh
	then
		bash	/home/engines/scripts/start.sh
	fi

touch /var/run/startup_complete 	
/usr/sbin/apache2ctl -D FOREGROUND 
 rm -f /run/apache2/apache2.p/home/engines//engines/run/startup_complete