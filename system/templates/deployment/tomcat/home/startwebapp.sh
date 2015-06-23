#!/bin/sh


PID_FILE=/engines/var/run/catalina.pid
export PID_FILE
. /home/trap.sh

CATALINA_PID=/engines/var/run/catalina.pid /usr/share/tomcat7/bin/catalina.sh  start 
 touch /var/run/flags/startup_complete
 wait 
 rm /var/run/flags/startup_complete
	

