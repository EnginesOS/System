#!/bin/sh

mkdir -p /engines/var/run/flags/

PID_FILE=/var/run/sshd.pid
export PID_FILE
. /home/trap.sh

mkdir -p /home/auth/logs/

if ! test -f /engines/var/run/flags/first_run.done
	then
		/home/auth/first_run.sh
		
		touch /engines/var/run/flags/first_run.done
	fi
	
 echo dbflavor=$dbflavor >/home/auth/.dbenv
 echo dbhost=$dbhost >>/home/auth/.dbenv
 echo dbname=$dbname >>/home/auth/.dbenv
 echo dbpasswd=$dbpasswd >>/home/auth/.dbenv
 echo dbuser=$dbuser >>/home/auth/.dbenv
	




SIGNAL=0
sudo /home/_start_syslog.sh
sudo /home/_start_sshd.sh
sudo /home/_start_kerobos.sh

touch /engines/var/run/flags/startup_complete
echo "startup complete"

 while test $SIGNAL -ne 3 -a $SIGNAL -ne 15
 do
  if test -f $PID_FILE
  	then
  	echo "waiting"
		wait 
		echo $SIGNAL
  fi
 done

sudo /home/engines/scripts/_kill_syslog.sh


rm -f /engines/var/run/flags/startup_complete
