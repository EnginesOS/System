#!/bin/sh

PID_FILE=/home/engines/run/engines.pid	
echo Pids PID_FILE=$PID_FILE>&2
export PID_FILE

if test -f /home/engines/functions/trap.sh 
 then
 . /home/engines/functions/trap.sh
 else
. /home/trap.sh
fi
echo trap Pids PID_FILE=$PID_FILE
. /home/engines/functions/start_functions.sh
echo start_functionsPids PID_FILE=$PID_FILE>&2
volume_setup
dynamic_persistence
echo Pids PID_FILE=$PID_FILE>&2
if test -f /home/_init.sh
 then
   /home/_init.sh
fi
echo Pids PID_FILE=$PID_FILE>&2
first_run
echo Pids PID_FILE=$PID_FILE>&2
restart_required
echo Pids PID_FILE=$PID_FILE>&2
pre_running
echo Pids PID_FILE=$PID_FILE>&2
custom_start
echo Pids PID_FILE=$PID_FILE>&2

touch  /home/engines/run/flags/started_once

if ! test -z $exit_start
 then
  exit
fi   

echo started_oncePids PID_FILE=$PID_FILE>&2
#for non apache framework (or use custom start)
if test -f /home/engines/scripts/start/startwebapp.sh 
 then
   launch_app
elif test -f /usr/sbin/apache2ctl
 then
 echo Pids PID_FILE=$PID_FILE
 if test -z $APACHE_PID_FILE
  then
  APACHE_PID_FILE=$PID_FILE
 else
  PID_FILE=$APACHE_PID_FILE
 fi
 export APACHE_PID_FILE PID_FILE
 echo start_apachePids PID_FILE=$PID_FILE APACHE_PID_FILE=$APACHE_PID_FILE>&2
   start_apache
elif test -d /etc/nginx
 then
 echo start_nginxPids PID_FILE=$PID_FILE APACHE_PID_FILE=$APACHE_PID_FILE>&2
   start_nginx	
elif test -f /home/engines/scripts/blocking.sh 
  then
	 /home/engines/scripts/blocking.sh  &
	 echo -n " $!" >>  $PID_FILE		   
else
 echo "Nothing to run!"
fi

startup_complete
wait 
exit_code=$?
shutdown_complete
exit $exit_code
