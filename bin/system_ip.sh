#!/bin/sh

interface=`netstat -nr | grep ^0.0.0.0 | awk '{print $8}'`
/sbin/ifconfig  $interface  |grep "inet addr" |cut -f2 -d: |cut -f1 -d" "	 | tr -d '\r\n'
