#!/bin/sh
touch /engines/var/run/startup_complete

/usr/sbin/cron -f -L 1
/usr/sbin/rsyslogd

rm /engines/var/run/startup_complete