#!/bin/sh

if ! test -f /home/engines/.ssh/engines_system.pub 
	then
		ssh-keygen  -P "" -f /home/engines/.ssh/engines_system >/dev/null
	fi
cat   /home/engines/.ssh/engines_system.pub 


