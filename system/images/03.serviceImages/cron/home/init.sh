#!/bin/sh
touch /engines/var/run/startup_complete

/usr/sbin/cron -f -L 1

rm /engines/var/run/startup_complete