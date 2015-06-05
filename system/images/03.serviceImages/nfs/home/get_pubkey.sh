#!/bin/sh

if test $1 = 'add' -o $1 = 'rm' -o $1 = 'access'
 then
	if test -f ~/.ssh/${1}_rsa.pub
		then
	 		cat ~/.ssh/${1}_rsa.pub | awk '{print $2}'	
 		else
 	 		ssh-keygen  -f ~/.ssh/${1}_rsa -P ""
 	 		cat ~/.ssh/${1}_rsa.pub | awk '{print $2}' 	 	
 	fi
 fi
 