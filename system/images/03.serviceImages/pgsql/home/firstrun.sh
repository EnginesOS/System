#!/bin/bash
pass="pass"
 if ! test -f /var/lib/postgresql/conf
 then
 echo "ALTER ROLE postgres WITH ENCRYPTED PASSWORD 'pass'; "| su  postgres  /usr/bin/perl   /usr/bin/psql -l
 echo listen_addresses = '*' >> /etc/postgresql/9.3/postgresql.conf
 echo "host all all 172.17.42.0/16  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
 touch /var/lib/postgresql/conf
	
 fi
	 
