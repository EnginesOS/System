#!/bin/sh

name=$1
file_prefix=/opt/engines/etc/certs/engines/${name}
chmod og-rw ${file_prefix}.key
chmod og-w ${file_prefix}.crt

	file $file_prefix.cert | grep PEM
	   if test $? -ne 0
 	then
		echo $name not a PEM certificate
		exit
	fi
	
	
		cp -p $file_prefix.crt   /opt/engines/etc/nginx/ssl/certs/$name.crt 
		chown 22005 /opt/engines/etc/nginx/ssl/certs/$name.crt 

		cp -p $file_prefix.key   /opt/engines/etc/nginx/ssl/keys/$name.key
		chown 22005 /opt/engines/etc/nginx/ssl/keys/$name.key
		
#Below here install default cert FIXME to only do so if asked and extend so individual certs can be installed per service ie imap. smtp.
		cp -p $file_prefix.crt /opt/engines/etc/ssl/certs/engines.crt
		chown 21000 /opt/engines/etc/ssl/certs/engines.crt

		cp -p $file_prefix.key /opt/engines/etc/ssl/keys/engines.key 
		chown 21000 /opt/engines/etc/ssl/engines.key 

		cp -p $file_prefix.crt /opt/engines/etc/ssl/smtp/engines.crt 
		chown 22003 /opt/engines/etc/ssl/smtp/engines.crt 

		cp -p $file_prefix.key /opt/engines/etc/ssl/smtp/keys/engines.key
		chown 22003 /opt/engines/etc/ssl/smtp/keys/engines.key
	
		cp -p $file_prefix.crt  /opt/engines/etc/ssl/imap/certs/engines.crt 
		chown 22013 /opt/engines/etc/ssl/imap/certs/engines.crt 

		cp -p $file_prefix.key /opt/engines/etc/ssl/imap/keys/engines.key 
		chown 22013 /opt/engines/etc/ssl/imap/keys/engines.key 

		cp -p $file_prefix.crt /opt/engines/etc/ssl/pgsql/certs/engines.crt
		chown 22002 /opt/engines/etc/ssl/pgsql/certs/engines.crt

		cp -p $file_prefix.key /opt/engines/etc/ssl/pgsql/private/engines.key
		chown 22002 /opt/engines/etc/ssl/pgsql/private/engines.key
  

		cp -p $file_prefix.crt   /opt/engines/etc/nginx/ssl/certs/engines.crt
		chown 22005 /opt/engines/etc/nginx/ssl/certs/engines.crt

		cp -p $file_prefix.key   /opt/engines/etc/nginx/ssl/keys/engines.key	
		chown 22005 /opt/engines/etc/nginx/ssl/keys/engines.key			

		



 