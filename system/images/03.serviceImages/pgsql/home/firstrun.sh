#!/bin/bash
pass="pass"
 if ! test -f /var/lib/postgresql/conf
 echo listen_addresses = '*' >> /etc/postgresql/9.3/main/postgresql.conf
 echo "host all all 172.17.42.0/16  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
 touch /var/lib/postgresql/conf
	
 fi
	 
