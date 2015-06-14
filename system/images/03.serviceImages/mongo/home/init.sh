#!/bin/sh


PID_FILE=/var/run/mongodb.pid
export PID_FILE
source /home/trap.sh

 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete

exec mongod   -v  -f /etc/mongod.conf  --directoryperdb    --journal  


rm /engines/var/run/startup_complete