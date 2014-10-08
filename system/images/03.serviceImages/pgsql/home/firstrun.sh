#!/bin/bash
pass="pass"

 	#Run First Time on persistent DB
 	
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
 	