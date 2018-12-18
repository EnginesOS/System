#!/bin/sh

if test $# -eq 0
then
a="-i"
else
a=$1
fi

if test $a = '-i'
	then
		docker inspect system |grep  \"IPAddress\": | head -1 | awk '{print $2}' |sed "/\,/s///" |sed "/\"/s///g"
	elif  test $a = '-d'
		then
		 ifconfig  docker0  |grep "inet addr" |cut -f2 -d: |cut -f1 -d" "	
	fi