#!/bin/sh

service=`echo $SSH_ORIGINAL_COMMAND |  awk -F/ '{print $6}'`
	if test -f /home/auth/static/access/$service/access
		then
			cat /home/auth/static/access/$service/access
		
else
	echo err with $SSH_ORIGINAL_COMMAND
fi
