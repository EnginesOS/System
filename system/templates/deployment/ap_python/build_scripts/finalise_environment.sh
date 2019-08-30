#!/bin/sh
mkdir  -p /var/log/apache2/ 
chown python /var/log/apache2/ 
mkdir  -p /run/apache2/ 
chown python /run/apache2/
if ! test -d /home/app/venv
 then
 mkdir -p /home/app/venv
fi

chown python -R /home/app/venv