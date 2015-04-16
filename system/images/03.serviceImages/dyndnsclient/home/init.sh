#!/bin/bash


while test 0 -ne 1
do
	ddclient   -f /home/dyndns/dyndns.conf -cache /home/dyndns/cache  -pid /home/dyndns/dyndns.pid
	sleep 300
done