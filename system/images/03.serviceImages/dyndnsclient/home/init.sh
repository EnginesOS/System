#!/bin/bash

mkdir -p  /home/dyndns/cache

while test 0 -ne 1
do
	ddclient -web -ssl -syslog -f /home/dyndns/dyndns.conf -cache /home/dyndns/cache  -pid /home/dyndns/dyndns.pid
	sleep 300
done