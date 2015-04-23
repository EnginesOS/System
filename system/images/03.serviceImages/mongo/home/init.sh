#!/bin/sh



 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete

exec mongod   -v  -f /etc/mongod.conf 


rm /engines/var/run/startup_complete