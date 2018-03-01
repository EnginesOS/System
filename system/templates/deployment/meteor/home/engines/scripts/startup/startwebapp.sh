#!/bin/bash

 if test $FRAMEWORK == 'meteor'
  then
  
  	PID_FILE=/home/engines/run/meteor.pid
  	cd /home/app
  	meteor &
  	pid=$!
  	startup_complete
  	echo $pid > $PID_FILE
  	. /home/trap.sh
  	wait 
  	shutdown_complete
  	exit
  fi