#!/bin/sh


PID_FILE=/home/engines/run/xapp.pid
export PID_FILE
. /home/trap.sh
 
sudo /usr/sbin/sshd -D -E /var/log/ssh.log &
sshd_pid=$!
echo $sshd_pid > $PID_FILE



 startup_complete
 wait 
 shutdown_complete
	

