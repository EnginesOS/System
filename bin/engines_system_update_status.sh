#!/bin/bash

cd /opt/engines

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