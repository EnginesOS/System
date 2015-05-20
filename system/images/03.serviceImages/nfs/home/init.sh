#!/bin/sh


sudo syslogd -R syslog.engines.internal:5140

#No need as uses exec
#PIDFILE=/var/run/ftpd.pid
#source /home/trap.sh

mkdir -p /engines/var/run/
	touch  /engines/var/run/startup_complete
	chown 21000 /engines/var/run/startup_complete	
	

sudo /etc/init.d/rpcbind start
#sudo /etc/init.d/rpcbind start
exec sudo  /usr/bin/ganesha.nfsd  -L /var/log/ganesha.log -f /usr/local/etc/ganesha.conf -F


