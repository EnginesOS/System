#!/bin/sh

mkdir -p /engines/var/run/flags/

PID_FILE=/var/run/sshd.pid
export PID_FILE
. /home/trap.sh

mkdir -p /home/auth/logs/

if test -f /home/auth/first_run.sh
	then
		/home/auth/first_run.sh
		mv /home/auth/first_run.sh /home/auth/first_run.done
		touch /engines/var/run/flags/first_run.done
	fi
	
 echo dbflavor=$dbflavor >/home/auth/.dbenv
 echo dbhost=$dbhost >>/home/auth/.dbenv
 echo dbname=$dbname >>/home/auth/.dbenv
 echo dbpasswd=$dbpasswd >>/home/auth/.dbenv
 echo dbuser=$dbuser >>/home/auth/.dbenv
	


sudo syslogd  -R syslog.engines.internal:5140

sudo /usr/sbin/sshd  -f /home/auth/ssh/sshd.conf -E /home/auth/logs/ssh.log &
touch /engines/var/run/flags/startup_complete
wait

rm -f /engines/var/run/flags/startup_complete
