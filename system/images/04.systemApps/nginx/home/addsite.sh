#!/bin/bash

cont=`echo $1 |cut -f1 -d:`
fqdn=`echo $1 |cut -f2 -d:`
port=`echo $1 |cut -f3 -d:`
host=`echo $fqdn |cut -f1 -d.`
 cat /home/tmpls/site.tmpl | sed "/SERVER/s//$host/" | sed "/FQDN/s//$fqdn/" | sed "/PORT/s//$port/" >/tmp/$fqdn.site
cp /tmp/$fqdn.site /etc/nginx/sites-enabled/
/etc/init.d/nginx reload

