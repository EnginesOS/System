#!/bin/sh


PID_FILE=/home/engines/run/catalina.pid
. /home/trap.sh

env CATALINA_PID=$PID_FILE  /usr/bin/java -Djava.util.logging.config.file=/usr/share/tomcat7/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.endorsed.dirs=/usr/share/tomcat7/endorsed -classpath /usr/share/tomcat7/bin/bootstrap.jar:/usr/share/tomcat7/bin/tomcat-juli.jar -Dcatalina.base=/usr/share/tomcat7 -Dcatalina.home=/usr/share/tomcat7 -Djava.io.tmpdir=/usr/share/tomcat7/temp org.apache.catalina.startup.Bootstrap &
echo $! 
 startup_complete
 wait `cat $PID_FILE`
shutdown_complete
	

