#/!bin/sh
engines service avahi state |grep -i running
 if test $? -eq 0
  then
  	engines service avahi stop
  	engines service avahi destroy
  	engines service avahi create
 fi