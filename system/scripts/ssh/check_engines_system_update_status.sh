#!/bin/bash

cd /opt/engines
release=`cat /opt/engines/release`
status=` git remote show origin |grep $release`
echo $status | grep  'local out of date' >/dev/null

if test $? -eq 0
 then
  echo $status > /opt/engines/run/system/flags/update_pending
	echo "Update Pending"
	echo $status
	exit 127
fi

echo "System Up to Date"
rm -f /opt/engines/run/system/flags/update_pending

exit 0