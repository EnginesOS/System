#!/bin/sh


#PIDFILE=/rub/auth.pid
#source /home/trap.sh




touch /var/run/startup_complete
exec syslogd -n -R syslog.engines.internal:5140


rm -f /engines/var/run/startup_complete
