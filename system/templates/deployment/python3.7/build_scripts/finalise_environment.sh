#!/bin/sh
mkdir  -p /var/log/apache2/ 
chown www-data /var/log/apache2/ 
mkdir  -p /run/apache2/ 
chown www-data /run/apache2/
if ! test -d /home/app/venv
 then
 mkdir -p /home/app/venv
fi

chown python -R /home/app/venv