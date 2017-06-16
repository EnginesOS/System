#!/bin/bash

PID_FILE=/var/run/engines/engines.pid	
export PID_FILE
. /home/trap.sh
. /home/engines/functions/start_functions.sh

volume_setup
dynamic_persistence

if test -f /home/_init.sh
 then
   /home/_init.sh
fi

first_run
restart_required
pre_running
custom_start


#for non apache framework (or use custom start)
if test -f /home/startwebapp.sh 
 then
   launch_app
elif test -f /usr/sbin/apache2ctl
 then
   start_apache
elif test -d /etc/nginx
 then
   start_nginx	
elif test -f /home/engines/scripts/blocking.sh 
  then
	 /home/engines/scripts/blocking.sh  &
	 echo -n " $!" >>  $PID_FILE		   
else
 echo "Nothing to run!"
 exit 127
fi
		
touch /engines/var/run/flags/startup_complete
wait `cat  $PID_FILE`
wait_for_debug
rm /engines/var/run/flags/startup_complete
