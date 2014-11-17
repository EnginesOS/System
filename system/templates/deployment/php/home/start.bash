#!/bin/bash

  if test  ! -f /engines/var/run/.volsetup
   then
   echo "Waiting for Volume setup to Complete "
 	while test ! -f /engines/var/run/.volsetup
 	  do
 	  echo  "."
 		sleep 10
 	 done
  fi
 
if test -f /home/engines/scripts/setup.bash
	then
		bash /home/engines/scripts/setup.bash
		mv /home/engines/scripts/setup.bash /home/engines/scripts/setup.bash.ran
	fi
	
if test -f /home/engines/scripts/pre-running.sh
	then
		bash	/home/engines/scripts/pre-running.sh
fi	

if test -n "$CRONJOBS"
then
	service cron start
fi

touch /var/run/startup_complete 	
/usr/sbin/apache2ctl -D FOREGROUND 
 rm -f /run/apache2/apache2.pid 
 rm /engines/var/run/startup_complete