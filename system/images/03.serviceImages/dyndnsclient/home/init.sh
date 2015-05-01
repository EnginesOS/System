#!/bin/bash

PIDFILE=/home/dyndns/dyndns.pid
source /home/trap.sh

while test 0 -ne 1
do
	ddclient   -file /home/dyndns/dyndns.conf -cache /home/dyndns/cache  -pid /home/dyndns/dyndns.pid
	sleep 300
done