#!/bin/sh

if test -f "~/.ssh/$1_rsa.pub"
	then
 		cat ~/.ssh/$1_rsa.pub | awk '{print $2}'
 	fi
 