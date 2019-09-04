#!/bin/sh

 . /home/app/venv/bin/activate
 export APACHE_RUN_USER=python
 export APACHE_RUN_GROUP=python
 . /etc/apache2/envvars
 echo Start Calling /home/_start.sh
 /home/_start.sh
 
