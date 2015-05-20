#!/bin/sh


#PIDFILE=/rub/auth.pid
#source /home/trap.sh
mkdir -p /home/auth/logs/

if test -f /home/auth/first_run.sh
	then
		/home/auth/first_run.sh
		mv /home/auth/first_run.sh /home/auth/first_run.done
	fi
	
 echo dbflavor=$dbflavor >/home/auth/.dbenv
 echo dbhost=$dbhost >>/home/auth/.dbenv
 echo dbname=$dbname >>/home/auth/.dbenv
 echo dbpasswd=$dbpasswd >>/home/auth/.dbenv
 echo dbuser=$dbuser >>/home/auth/.dbenv
	

touch /var/run/startup_complete

sudo syslogd  -R syslog.engines.internal:5140

exec /usr/sbin/sshd -D -f /home/auth/ssh/sshd.conf -E /home/auth/logs/ssh.log
 
 

rm -f /engines/var/run/startup_complete
