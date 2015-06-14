#!/bin/bash

PIDFILE=/home/dyndns/dyndns.pid
export PIDFILE
source /home/trap.sh



	ddclient   -file /home/dyndns/dyndns.conf -cache /home/dyndns/cache  -pid /home/dyndns/dyndns.pid &
	
	wait $!