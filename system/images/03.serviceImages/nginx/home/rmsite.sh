#!/bin/bash
cont=`echo $1 |cut -f1 -d:`
fqdn=`echo $1 |cut -f2 -d:`
port=`echo $1 |cut -f3 -d:`
host=`echo $fqdn |cut -f1 -d.`

rm /etc/nginx/sites-enabled/*_$fqdn.site
service nginx restart

