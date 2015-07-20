#!/bin/sh

chmod og-rw ${1}.key
chmod og-w ${1}.cert
	if test $1 = -d
		then
			name=$2
			file $name | grep PEM
				 if test $? -ne 0
 					then
						echo $name not a PEM certificate
					exit
				fi
			
		cp $name.crt /opt/engines/etc/ssl/certs/
		chown 21000 /opt/engines/etc/ssl/certs/engines.crt

		cp $name.key /opt/engines/etc/ssl/keys/
		chown 21000 /opt/engines/etc/ssl/engines.key 

		cp $name.crt /opt/engines/etc/ssl/smtp/
		chown 22003 /opt/engines/etc/ssl/smtp/engines.crt 

		cp $name.key /opt/engines/etc/ssl/smtp/keys
		chown 22003 /opt/engines/etc/ssl/smtp/keys/engines.key
	
		cp $name.crt  /opt/engines/etc/ssl/imap/certs
		chown 22013 /opt/engines/etc/ssl/imap/certs/engines.crt 

		cp $name.key /opt/engines/etc/ssl/imap/keys
		chown 22013 /opt/engines/etc/ssl/imap/keys/engines.key 

		cp $name.crt /opt/engines/etc/ssl/pgsql/certs
		chown 22002 /opt/engines/etc/ssl/pgsql/certs/engines.crt

		cp $name.key /opt/engines/etc/ssl/pgsql/private
		chown 22002 /opt/engines/etc/ssl/pgsql/private/engines.key
  

		cp $name.crt   /opt/engines/etc/nginx/ssl/certs
		chown 22005 /opt/engines/etc/nginx/ssl/certs/engines.crt

		cp $name.key   /opt/engines/etc/nginx/ssl/keys
		chown 22005 /opt/engines/etc/nginx/ssl/keys/engines.key
		
	else
		name=$1
	fi
	file $name | grep PEM
	   if test $? -ne 0
 	then
		echo $name not a PEM certificate
		exit
	fi
		cp $name.crt   /opt/engines/etc/nginx/ssl/certs/$name.crt 
		chown 22005 /opt/engines/etc/nginx/ssl/certs/$name.crt 

		cp $name.key   /opt/engines/etc/nginx/ssl/keys/$name.key
		chown 22005 /opt/engines/etc/nginx/ssl/keys/$name.key



 