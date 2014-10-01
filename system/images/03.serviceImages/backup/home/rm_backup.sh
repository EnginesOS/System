#!/bin/sh
 echo "$*" >>/var/log/rmbackup.log
if test -n $1
	then
		rm -r /etc/duply/$1
	fi

      