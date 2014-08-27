FROM  engines-os/base
RUN apt-get install -y   tomcat7 
RUN ln -s /var/log/tomcat7 /usr/share/tomcat7/logs
RUN ln -s  /etc/tomcat7  /usr/share/tomcat7/conf
RUN ln -s /tmp /usr/share/tomcat7/temp

ADD home home
#RUN rmdir /usr/share/tomcat7/webapps
ADD home/webapps/ /usr/share/tomcat7/webapps
EXPOSE 8080
