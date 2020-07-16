#!/bin/sh

if ! test -f /home/engines/.ssh/system/engines_system.pub 
	then
		ssh-keygen  -P "" -f /home/engines/.ssh/system/engines_system >/dev/null
	fi
cat   /home/engines/.ssh/system/engines_system.pub 


