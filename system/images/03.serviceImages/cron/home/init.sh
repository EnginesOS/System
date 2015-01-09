#!/bin/sh
touch /engines/var/run/startup_complete

/usr/sbin/cron -f

rm /engines/var/run/startup_complete