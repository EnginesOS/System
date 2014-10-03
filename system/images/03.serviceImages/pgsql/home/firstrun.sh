#!/bin/bash
pass="pass"
 if ! test -f /var/lib/postgresql
 then
 echo "ALTER ROLE postgres WITH ENCRYPTED PASSWORD 'pass'; " |su -l postgres psql
 echo listen_addresses = '*' >> /etc/postgresql/9.1/postgresql.conf
 echo "host all all 172.17.42.0/16  md5" >> /etc/postgresql/9.1/main/pg_hba.conf
 
	
 fi
	 
