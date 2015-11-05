#!/bin/bash

cd /opt/engines
if test -f /opt/engines/run/system/flags/test_engines_update
 then
   echo "Update Pending"
	echo "Faking it because of /opt/engines/run/system/flags/test_engines_update "
	exit 255
 fi
 
status=` git remote show origin`
echo $status |grep  'local out of date' >/dev/null
if test $? -eq 0
 then
	echo "Update Pending"
	echo $status
	exit 255
fi
echo "System Up to Date"
exit 0