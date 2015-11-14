#!/bin/sh

ip=`/opt/engines/bin/get_ip.sh`
echo -n $ip > /opt/engines/etc/net/ip
