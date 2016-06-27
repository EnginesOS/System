#/!bin/sh
engines_tool service avahi state |grep -i running
 if test $? -eq 0
  then
  	engines_tool service avahi stop
  	engines_tool service avahi destroy
  	engines_tool service avahi create
 fi