#!/bin/bash

 if test $FRAMEWORK == 'meteor'
  then
  	cd /home/app
  	~node/.meteor/meteor &
  	pid=$!
  	touch /engines/var/run/flags/startup_complete
  	echo $pid > /run/meteor.pid
  	PID_FILE=/run/meteor.pid
  	. /home/trap.sh
  	wait 
  	rm /engines/var/run/flags/startup_complete
  	exit
  fi