#!/bin/bash

cd /opt/engines

git status -u no |grep  up-to-date >/dev/null
if test $? -ne 0
 then
	echo "Update Pending"
	exit 255
fi
echo "System Up to Date"
exit 0