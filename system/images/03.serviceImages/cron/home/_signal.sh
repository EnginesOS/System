#!/bin/sh


if test -f /run/syslogd.pid -a $SIGNAL -ne 1
	then
		kill -TERM `cat /run/syslogd.pid`
	fi
	