#!/bin/sh


 name=$1

 rm  /opt/engines/etc/ssl/keys/${name}.key
 rm  /opt/engines/etc/ssl/certs/${name}.crt
  if test -f /opt/engines/etc/nginx/ssl/certs/$name.crt 
   then
 		rm  /opt/engines/etc/nginx/ssl/certs/$name.crt
 	fi
 	 if test -f  /opt/engines/etc/nginx/ssl/keys/$name.key
 	  then
 			rm /opt/engines/etc/nginx/ssl/keys/$name.key
 	fi
