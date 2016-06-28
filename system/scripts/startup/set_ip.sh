#!/bin/sh

ip=`/opt/engines/bin/system_ip.sh`
echo -n $ip > /opt/engines/etc/net/ip
