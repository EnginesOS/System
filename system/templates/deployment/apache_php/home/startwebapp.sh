#!/bin/sh


touch /var/run/startup_complete


PIDFILE=/run/apache2/apache2.pid
export PIDFILE
source /home/trap.sh


	if test -f /home/blocking.sh
		then
		/etc/init.d/apache2 start
			bash /home/blocking.sh &
	else		
		/usr/sbin/apache2ctl start
	fi

wait $!


