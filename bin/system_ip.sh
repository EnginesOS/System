#!/bin/bash
if test $1 = '-i'
	then
		docker inspect system |grep  \"IPAddress\": | head -1 | awk '{print $2}' |sed "/\,/s///" |sed "/\"/s///g"
	elif  test $1 = '-d'
		then
		 ifconfig  docker0  |grep "inet addr" |cut -f2 -d: |cut -f1 -d" "	
	fi