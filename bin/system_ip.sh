#!/bin/bash

interface=`netstat -nr | grep ^0.0.0.0 | awk '{print $8}'`
/sbin/ifconfig  $interface  |grep "inet " |awk '{print $2}'
