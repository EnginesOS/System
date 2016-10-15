#!/bin/sh
#FIXMe should be a link
ip=`/opt/engines/bin/system_ip.sh`
echo -n $ip > /opt/engines/etc/net/ip
curl ipecho.net/plain > /opt/engines/etc/net/public
