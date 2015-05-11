#!/bin/sh

if test -f ~/.ssh/${1}_rsa.pub
	then
 		cat ~/.ssh/${1}_rsa.pub | awk '{print $2}'
 	fi
 