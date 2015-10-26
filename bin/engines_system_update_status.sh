#!/bin/bash

cd /opt/engines
if test -f /opt/engines/run/system/flags/test_engines_update
 then
   echo "Update Pending"
	echo $status
	exit 255
 fi
 
status=`git status -u no`
echo $status |grep  up-to-date >/dev/null
if test $? -ne 0
 then
	echo "Update Pending"
	echo $status
	exit 255
fi
echo "System Up to Date"
exit 0