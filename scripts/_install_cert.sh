#!/bin/sh

name=$1
cert=/opt/engines/etc/ssl/certs/${name}
key=/opt/engines/etc/ssl/keys/${name}
chmod og-rw ${key}.key
chmod og-w ${cert}.crt

	file $cert.crt | grep PEM
	   if test $? -ne 0
 	then
		echo $name not a PEM certificate
		exit
	fi
	
	#AS DOMAIN CERT for NGINX
		cp -p $cert.crt   /opt/engines/etc/nginx/ssl/certs/$name.crt 
		chown 22005 /opt/engines/etc/nginx/ssl/certs/$name.crt 
		chmod og-rw /opt/engines/etc/nginx/ssl/certs/$name.crt 
		cp -p $key.key   /opt/engines/etc/nginx/ssl/keys/$name.key
		chown 22005 /opt/engines/etc/nginx/ssl/keys/$name.key
		chmod og-rw /opt/engines/etc/nginx/ssl/keys/$name.key
		
#Below here install default cert FIXME to only do so if asked and extend so individual certs can be installed per service ie imap. smtp.
#		cp -p $cert.crt /opt/engines/etc/ssl/certs/engines.crt
#		chown 21000 /opt/engines/etc/ssl/certs/engines.crt
		chmod og-rw 
#		cp -p $key.key /opt/engines/etc/ssl/keys/engines.key 
#		chown 21000 /opt/engines/etc/ssl/engines.key 

		cp -p $cert.crt /opt/engines/etc/ftp/ssl/engines.crt 
		chown 22003 /opt/engines/etc/ftp/ssl/engines.crt 
		chmod og-rw /opt/engines/etc/ftp/ssl/engines.crt 
		cp -p $key.key /opt/engines/etc/ftp/ssl/keys/engines.key
		chown 22003 /opt/engines/etc/ftp/ssl/keys/engines.key
		chmod og-rw /opt/engines/etc/ftp/ssl/keys/engines.key

		cp -p $cert.crt /opt/engines/etc/smtp/ssl/engines.crt 
		chown 22003 /opt/engines/etc/smtp/ssl/engines.crt 
		chmod og-rw /opt/engines/etc/smtp/ssl/engines.crt 
		cp -p $key.key /opt/engines/etc/smtp/ssl/keys/engines.key
		chown 22003 /opt/engines/etc/smtp/ssl/keys/engines.key
		chmod og-rw /opt/engines/etc/smtp/ssl/keys/engines.key
	
		cp -p $cert.crt  /opt/engines/etc/imap/ssl/certs/engines.crt 
		chown 22013 /opt/engines/etc/imap/ssl/certs/engines.crt 
		chmod og-rw /opt/engines/etc/imap/ssl/certs/engines.crt 
		cp -p $key.key /opt/engines/etc/imap/ssl/keys/engines.key 
		chown 22013 /opt/engines/etc/imap/ssl/keys/engines.key 
		chmod og-rw /opt/engines/etc/imap/ssl/keys/engines.key 
		
		cp -p $cert.crt /opt/engines/etc/pgsql/ssl/certs/engines.crt
		chown 22002 /opt/engines/etc/pgsql/ssl/certs/engines.crt
		chmod og-rw /opt/engines/etc/pgsql/ssl/certs/engines.crt
		cp -p $key.key /opt/engines/etc/pgsql/ssl/private/engines.key
		chown 22002 /opt/engines/etc/pgsql/ssl/private/engines.key
  		chmod og-rw /opt/engines/etc/pgsql/ssl/private/engines.key
  		
#AS Default Cert Nginx
		cp -p $cert.crt   /opt/engines/etc/nginx/ssl/certs/engines.crt
		chown 22005 /opt/engines/etc/nginx/ssl/certs/engines.crt
		chmod og-rw /opt/engines/etc/nginx/ssl/certs/engines.crt
		cp -p $key.key   /opt/engines/etc/nginx/ssl/keys/engines.key	
		chown 22005 /opt/engines/etc/nginx/ssl/keys/engines.key			
		chmod og-rw /opt/engines/etc/nginx/ssl/keys/engines.key	
	


 