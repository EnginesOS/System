#!/bin/bash

 if test $FRAMEWORK == 'meteor'
  then
  	cd /home/app
  	meteor &
  	pid=$!
  	startup_complete
  	echo $pid > /tmp/meteor.pid
  	PID_FILE=/tmp/meteor.pid
  	. /home/trap.sh
  	wait 
  	shutdown_complete
  	exit
  fi