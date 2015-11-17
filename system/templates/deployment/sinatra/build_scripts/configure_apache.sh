#!/bin/bash


cat /etc/apache2/sites-enabled/000-default.conf  | sed "s/^#SERVER_NAME/ ServerName $fqdn/" > /tmp/.000-default.conf
cp /tmp/.000-default.conf  /etc/apache2/sites-enabled/000-default.conf 
echo  ServerName $fqdn > /tmp/apache2.conf
cat /etc/apache2/apache2.conf >> /tmp/apache2.conf
mv /tmp/apache2.conf /etc/apache2/apache2.conf 