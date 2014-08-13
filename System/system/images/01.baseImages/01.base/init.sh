#!/bin/bash

/home/dns-init.sh

if test -f /home/app.env
	then
		. /home/app.env
		export ` cat /home/app.env |grep = |cut -f1 -d=`
	fi

#if test -f /etc/sudoers
#	then 
#		chown 0 /etc/sudoers
#	fi

if test -f /home/pre-running.sh
	 then
         	bash /home/pre-running.sh
  fi



if test -f /home/startwebapp.sh

        then
 		bash /home/startwebapp.sh
        fi
if test -f /home/startworker.sh
        then
         	bash /home/startworker.sh
        fi

#if test -f /etc/profile.d/rvm.sh
#then
#	source /etc/profile.d/rvm.sh
#fi

if test -z $ContUser
	then
		ContUser=www-data
fi

if test -f /home/app/Procfile.sh
        then
		cd /home/app/
                su -l  $ContUser   /home/app/Procfile.sh
        fi



