#!/bin/sh


SIGNAL=0

/usr/sbin/sshd  -f /home/auth/ssh/sshd.conf -E /home/auth/logs/ssh.log &

 while test $SIGNAL -ne 3 -a $SIGNAL -ne 15
 do
  if test -f $PID_FILE
  	then
		wait `cat $PID_FILE`
		echo $SIGNAL
  fi
 done

kill -TERM `cat /run/syslogd.pid`