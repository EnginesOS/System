#!/bin/sh


#PIDFILE=/rub/auth.pid
#source /home/trap.sh


if test -f /home/auth/first_run.sh
	then
		/home/auth/first_run.sh
		mv /home/auth/first_run.sh /home/auth/first_run.done
	fi

touch /var/run/startup_complete

syslogd  -R syslog.engines.internal:5140

exec /usr/sbin/sshd -D -f /home/auth/ssh/sshd_config
 


rm -f /engines/var/run/startup_complete
