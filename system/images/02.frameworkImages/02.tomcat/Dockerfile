FROM engines/frameworkbase
RUN apt-get -y  --force-yes update;\
	/usr/sbin/usermod -u 22671 www-data;\
	apt-get install -y   tomcat7 ;\
	ln -s /var/log/tomcat7 /usr/share/tomcat7/logs;\
 	ln -s  /etc/tomcat7  /usr/share/tomcat7/conf;\
 	ln -s /tmp /usr/share/tomcat7/temp

ADD home home

ADD home/webapps/ /usr/share/tomcat7/webapps

ENV ContUser www-data
ENV ContGrp www-data