#!/bin/sh


ifconfig  docker0  |grep "inet" |head -1 |awk '{print $2}' |cut -f2 -d:
