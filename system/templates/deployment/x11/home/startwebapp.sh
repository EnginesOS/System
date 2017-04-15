#!/bin/sh


PID_FILE=/tmp/running_apps.pid
export PID_FILE
. /home/trap.sh
 
sudo /usr/sbin/sshd -D -E /home/app/logs/ssh.log &
sshd_pid=$!
echo $sshd_pid > /tmp/running_apps.pid



 touch /engines/var/run/flags/startup_complete
 wait $sshd_pid
 rm /engines/var/run/flags/startup_complete
	

