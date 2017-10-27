#!/bin/bash

 if test $FRAMEWORK == 'meteor'
  then
  	cd /home/app
  	meteor &
  	pid=$!
  	touch /home/engines/run/flags/startup_complete
  	echo $pid > /tmp/meteor.pid
  	PID_FILE=/tmp/meteor.pid
  	. /home/trap.sh
  	wait 
  	rm /home/engines/run/flags/startup_complete
  	exit
  fi