FROM engines/frameworkbase
RUN apt-get -y  --force-yes update
RUN apt-get install -y   tomcat7 
RUN ln -s /var/log/tomcat7 /usr/share/tomcat7/logs
RUN ln -s  /etc/tomcat7  /usr/share/tomcat7/conf
RUN ln -s /tmp /usr/share/tomcat7/temp

ADD home home

ADD home/webapps/ /usr/share/tomcat7/webapps
EXPOSE 8080


ENV ContUser www-data
ENV ContGrp www-data