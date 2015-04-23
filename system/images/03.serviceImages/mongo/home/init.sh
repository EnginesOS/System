#!/bin/sh



 
mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete

 su mongo -c  "mongod   -v  -f /etc/mongod.conf "


rm /engines/var/run/startup_complete