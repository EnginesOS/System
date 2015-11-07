#!/bin/bash

apt-get -y remove  build-essential gcc make 
apt-get -y clean 

mkdir  -p /var/log/apache2/ 
chown www-data /var/log/apache2/ 
mkdir  -p /run/apache2/ 
chown www-data /run/apache2/