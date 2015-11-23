#!/bin/sh

pid=`ps -ax |grep -v grep |grep "docker build --force" | awk '{ print $1}'`
 if ! test -z "$pid"
  then
	kill -HUP $pid
 fi