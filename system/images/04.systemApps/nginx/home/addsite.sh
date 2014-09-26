#!/bin/bash

cont=`echo $1 |cut -f1 -d:`
fqdn=`echo $1 |cut -f2 -d:`
port=`echo $1 |cut -f3 -d:`
host=`echo $fqdn |cut -f1 -d.`

protos=`echo $1 |cut -f4 -d:`

	if test -z "$protos"
		then
			protos="http"
	fi

 for proto in $protos
 do
	if test "https" = $proto
		then
		 	if test -f /etc/nginx/ssl/certs/$fqdn.crt
		 		then
		 			certname=$fqdn
		 		else
		 			dn=`cat $fqdn | awk -F.  '{for(i=1;i<2;i++) $i="";print}' |tr ' ' '.' |sed "/./s///"`
		 			if test -f /etc/nginx/ssl/certs/$dn.crt
		 				then
		 					certname=$dn
		 				else
		 					certname="engines"
		 			fi
		 			
		 	fi
	fi	
		

 cat /home/tmpls/${proto}_site.tmpl | sed "/CERTNAME/s//$certname/"  | sed "/SERVER/s//$host/" | sed "/FQDN/s//$fqdn/" | sed "/PORT/s//$port/" >/tmp/${proto}_$fqdn.site
cp /tmp/${proto}_$fqdn.site /etc/nginx/sites-enabled/

done
service nginx restart

