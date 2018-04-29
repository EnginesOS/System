#!/bin/sh

ip=`/opt/engines/bin/system_ip.sh`
echo -n $ip > /opt/engines/etc/exported/net/ip
curl -k ipecho.net/plain > /opt/engines/etc/exported/net/public