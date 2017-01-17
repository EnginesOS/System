#/!bin/sh
/opt/engines/bin/engines service avahi state |grep -i running
 if test $? -eq 0
  then
  	/opt/engines/bin/engines service avahi stop
  	/opt/engines/bin/engines service avahi destroy
  	/opt/engines/bin/engines service avahi create
 fi