#!/bin/bash

mkdir  -p /var/log/apache2/ 
chown www-data /var/log/apache2/ 
mkdir  -p /run/apache2/ 
chown www-data /run/apache2/
chown -R www-data /usr/share/tomcat7/work/Catalina/localhost/