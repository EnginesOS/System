#!/bin/sh
Backup_ConfigDir=/home/backup/.duply/
 echo "$*" >>/var/log/backup//rmbackup.log
if test -n $1
	then
		rm -r $Backup_ConfigDir/$1
	fi

      