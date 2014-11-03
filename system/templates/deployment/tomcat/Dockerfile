FROM  enginesos/tomcat
ADD home home
ADD engines home/engines
#ADD home/app/webapps/ /usr/share/tomcat7/webapps
RUN chown 2669 /app/webapps/ /usr/share/tomcat7/webapps /home/app `find /var /usr/share /usr/local /home -user www-data`
RUN /usr/sbin/usermod -u 2669 www-data
