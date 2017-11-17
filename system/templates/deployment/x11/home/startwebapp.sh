#!/bin/sh


PID_FILE=/tmp/running_apps.pid
export PID_FILE
. /home/trap.sh
 
sudo /usr/sbin/sshd -D -E /var/log/ssh.log &
sshd_pid=$!
echo $sshd_pid > /tmp/running_apps.pid



 startup_complete
 wait $sshd_pid
 shutdown_complete
	

