#!/bin/bash

PID_FILE=/home/dyndns/dyndns.pid
export PID_FILE
source /home/trap.sh



	ddclient   -file /home/dyndns/dyndns.conf -cache /home/dyndns/cache  -pid /home/dyndns/dyndns.pid &
	
	wait $!