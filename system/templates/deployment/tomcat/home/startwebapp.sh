#!/bin/sh

 /usr/share/tomcat7/bin/catalina.sh  start &
 touch /var/run/flags/startup_complete
 wait
 rm /var/run/flags/startup_complete
	

