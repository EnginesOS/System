#!/bin/sh





PID_FILE=/run/apache2/apache2.pid
export PID_FILE
source /home/trap.sh


	if test -f /home/blocking.sh
		then
		/etc/init.d/apache2 start
			bash /home/blocking.sh &
	else		
		
		/usr/sbin/apache2ctl -DFOREGROUND &
		touch /engines/var/run/flags/startup_complete
	fi

wait 

rm /engines/var/run/flags/startup_complete
