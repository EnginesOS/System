#!/bin/sh

PID_FILE=/var/spool/postfix/pid/master.pid

export PID_FILE
. /home/trap.sh

mkdir -p /engines/var/run/flags/
sudo -n /sbin/syslogd -R syslog.engines.internal:5140

sudo -n postmap /etc/postfix/transport 
sudo -n postmap /etc/postfix/smarthost_passwd
sudo -n /usr/lib/postfix/master &

	
 echo dbflavor=$dbflavor >/home/auth/.dbenv
 echo dbhost=$dbhost >>/home/auth/.dbenv
 echo dbname=$dbname >>/home/auth/.dbenv
 echo dbpasswd=$dbpasswd >>/home/auth/.dbenv
 echo dbuser=$dbuser >>/home/auth/.dbenv

cat /home/app/_config.inc.php |\
 sed "/DBHOST/s/$dbhost//"\
	 "/DBNAME/s/$dbname//"\
	 "/DBUSER/s/$dbuser//"\
	  "/DBPASSWD/s/$dbpasswd//" > /home/app/config.inc.php

sudo -n  /usr/sbin/apache2ctl  -DFOREGROUND & 
touch /engines/var/run/flags/startup_complete  
wait 
rm -f /engines/var/run/flags/startup_complete
sudo /home/engines/scripts/_kill_syslog.sh

 
 

