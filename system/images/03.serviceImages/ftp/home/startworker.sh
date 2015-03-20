#!/bin/sh


syslogd -R syslog.engines.internal:5140

mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete
proftpd -n


rm /engines/var/run/startup_complete