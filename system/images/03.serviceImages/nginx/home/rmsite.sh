#!/bin/bash
cont=`echo $1 |cut -f1 -d:`
fqdn=`echo $1 |cut -f2 -d:`
port=`echo $1 |cut -f3 -d:`
host=`echo $fqdn |cut -f1 -d.`

result="FAIL"

	if test  -f /etc/nginx/sites-enabled/http_$fqdn.site
		then
			rm /etc/nginx/sites-enabled/http_$fqdn.site
			result="OK"
	fi
	
	if test -f /etc/nginx/sites-enabled/https_$fqdn.site
		then
			rm /etc/nginx/sites-enabled/https_$fqdn.site
			result="OK"
	fi

echo $result

	if test $result == "OK"
		then
			service nginx reload
	fi

