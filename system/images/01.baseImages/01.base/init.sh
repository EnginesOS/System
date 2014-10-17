#!/bin/bash

/home/dns-init.sh

if test -f /home/firstrun.sh 
	 then
        bash /home/firstrun.sh 
        mv /home/firstrun.sh /home/firstrun.sh.save
fi

if test -f /home/app.env
	then
		. /home/app.env
		export ` cat /home/app.env |grep = |cut -f1 -d=`
fi

if test -z $ContUser
	then
		ContUser=www-data
fi

if  test -z $ContGrp
     then
          ContGrp=www-data
fi

if test -f /home/.logsetup
 then
	if test -f /home/LOG_DIR
	then
		log_dir=`cat /home/LOG_DIR`
	else
		log_dir="/var/log/"
	fi
		if test ! $log_dir = "/var/log/"
			then
				mkdir -p $log_dir
				chown -R $ContUser $log_dir
		fi
	touch /home/.logsetup
fi
	
#for setup of services 
if test -f /home/pre-running.sh
	 then
        bash /home/pre-running.sh
fi

#only for daemons that set user as in apace and tomcat
if test -f /home/startwebapp.sh
   then					
   		bash /home/startwebapp.sh
fi
        
#work process includes not yet setup web frameworks

if test -f /home/startworker.sh
   then
   		#FIXME Need to launch as workeruser
       	bash /home/startworker.sh
fi

#rails
					
if test -f /home/app/Procfile.sh
        then
		cd /home/app/	
        su -l  $ContUser   /home/app/Procfile.sh
fi


 
