#!/bin/bash

args=$SSH_ORIGINAL_COMMAND

console_password=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $2}' | sed  '/:$/s///'`

echo $console_password

if test -z $console_password
 then
 	echo Error:no Console Password
 	exit -1
 fi
 
 sudo /opt/engines/scripts/_update_engines_console_password.sh '$console_password'
 