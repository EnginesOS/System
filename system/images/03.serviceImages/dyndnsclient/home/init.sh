#!/bin/bash

PID_FILE=/home/dyndns/dyndns.pid
export PID_FILE
. /home/trap.sh


mkdir -p /engines/var/run/flags/

	ddclient   -file /home/dyndns/dyndns.conf -cache /home/dyndns/cache  -pid /home/dyndns/dyndns.pid &
	touch /engines/var/run/flags/startup_complete
	wait 
	rm /engines/var/run/flags/startup_complete