#!/bin/bash

cd /opt/engines

 
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