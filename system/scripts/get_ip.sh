#!/bin/sh

gw_ifac=`netstat -nr |grep ^0.0.0.0 | awk '{print $8}' |head -1`
echo $gw_ifac >/opt/engines/etc/exported/net/gateway_interface
ip=`/sbin/ifconfig $gw_ifac |grep "inet addr"  |  cut -f 2 -d: |cut -f 1 -d" "`
echo  $ip 
