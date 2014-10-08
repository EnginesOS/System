#!/bin/bash
pass="pass"
	echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
 	echo "host all all 172.17.42.0/16  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
 	
 if ! test -f /var/lib/postgresql/conf
 then


cp -rp /var/lib/postgresql_firstrun/* /var/lib/postgresql/ 

chown -R postgres /var/lib/postgresql
mkdir -p /var/log/postgresql
chown postgres -R /var/log/postgresql

 service postgresql start
 
 	touch /var/lib/postgresql/conf
	 echo "ALTER ROLE postgres WITH ENCRYPTED PASSWORD 'pass'; " > /tmp/t.sql
	 echo "/usr/bin/perl   /usr/bin/psql -l" > /tmp/t.sh
	 chmod +x /tmp/t.sh
	  su postgres  /tmp/t.sh
	  
	  rm /tmp/t.sh
	  rm /tmp/t.sql
	 
 fi
	 
