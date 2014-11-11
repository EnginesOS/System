FROM  engines/tomcat
ADD home home
ADD engines home/engines
#ADD home/app/webapps/ /usr/share/tomcat7/webapps
RUN chown 2669  /usr/share/tomcat7/webapps  `find /var /usr/share /usr/local /home -user www-data`;\
	/usr/sbin/usermod -u 2669 www-data;\
	mkdir -p /home/app/webapps/ ;\
	rm -r /usr/share/tomcat7/webapps;\
	ln -s /home/app/webapps /usr/share/tomcat7/
	