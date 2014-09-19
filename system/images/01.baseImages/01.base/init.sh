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


 
