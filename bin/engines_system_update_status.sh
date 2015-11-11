#!/bin/bash

cd /opt/engines
if test -f /opt/engines/run/system/flags/skip_engines_update_check
 then
	echo "System Up to Date"
	exit 0
 fi
 
if test -f /opt/engines/run/system/flags/test_engines_update
 then
   echo "Update Pending"
	echo "Faking it because of /opt/engines/run/system/flags/test_engines_update "
	exit 255
 fi
 
if test `cat /opt/engines/release` = current
  then
	 if ! test -f /opt/engines/run/system/flags/check_engines_update_everytime
  		then
    		if test -f /opt/engines/run/system/flags/update_pending
     			then 
      				cat /opt/engines/run/system/flags/update_pending
      				exit 127
 			else
  				echo "System Up to Date"
  				exit 0 
  			fi
  	fi
fi

 
release=`cat /opt/engines/release`
status=` git remote show origin $release`
echo $status |grep  'local out of date' >/dev/null
if test $? -eq 0
 then
  echo $status > /opt/engines/run/system/flags/update_pending
	echo "Update Pending"
	echo $status
	exit 255
 else
  rm -f /opt/engines/run/system/flags/update_pending
fi
echo "System Up to Date"
rm -f /opt/engines/run/system/flags/update_pending
exit 0