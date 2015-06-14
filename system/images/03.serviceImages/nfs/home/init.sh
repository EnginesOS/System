#!/bin/sh

sudo syslogd -R syslog.engines.internal:5140


PID_FILE=/var/run/ganesha.pid
export PID_FILE
source /home/trap.sh

mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
		
sudo /etc/init.d/rpcbind start

 sudo  /usr/bin/ganesha.nfsd  -L /var/log/ganesha.log -f /usr/local/etc/ganesha.conf &
wait $!


