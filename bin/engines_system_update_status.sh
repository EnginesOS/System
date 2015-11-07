#!/bin/bash

cd /opt/engines
if test -f /opt/engines/run/system/flags/test_engines_update
 then
   echo "Update Pending"
	echo "Faking it because of /opt/engines/run/system/flags/test_engines_update "
	exit 255
 fi
 
release=`cat /opt/engines/release`
status=` git remote show origin $release`
echo $status |grep  'local out of date' >/dev/null
if test $? -eq 0
 then
 touch /opt/engines/run/system/flags/update_pending
	echo "Update Pending"
	echo $status
	exit 255
fi
echo "System Up to Date"
rm /opt/engines/run/system/flags/update_pending
exit 0