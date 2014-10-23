#!/bin/sh

mkdir -p /var/log/volmgr
chown $ContUser.$CountGrp /var/log/volmgr



mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30

while test -f /var/run/sshd.pid
	do
	  sleep 200
	done


