#!/bin/bash
pass="pass"
 if ! test -f /var/lib/postgresql/conf
 then
 	echo listen_addresses = '*' >> /etc/postgresql/9.3/main/postgresql.conf
 	echo "host all all 172.17.42.0/16  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
 	touch /var/lib/postgresql/conf
	 echo "ALTER ROLE postgres WITH ENCRYPTED PASSWORD 'pass'; " > /tmp/t.sql
	 echo /usr/bin/perl   /usr/bin/psql -l > /tmp/t.sh
	 chmod +x /tmp/t.sh
	  su postgres  /tmp/t.sh
	  
	  rm /tmp/t.sh
	  rm /tmp/t.sql
	 
 fi
	 
l