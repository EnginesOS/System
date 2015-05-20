#!/bin/bash
pass="pass"

 	#Run First Time on persistent DB
 	
 if ! test -f /var/lib/postgresql/conf
 then
 
 	 chown -R postgres /var/lib/postgresql
	 chown postgres -R /var/log/postgresql
	 
	cp -rp /var/lib/postgresql_firstrun/* /var/lib/postgresql/ 

	chown -R postgres /var/lib/postgresql
	mkdir -p /var/log/postgresql
	chown postgres -R /var/log/postgresql
	
 	postgres  service postgresql start
   pass=pass
   
 	touch /var/lib/postgresql/conf 	
 #	psql template1 -c 'create extension hstore;'
	 echo "ALTER ROLE postgres WITH ENCRYPTED PASSWORD '$pass'; " > /tmp/t.sql
	 echo "create ROLE rma WITH ENCRYPTED PASSWORD '$pass'; " >> /tmp/t.sql
	 echo "Alter ROLE rma WITH superuser;" >> /tmp/t.sql
	 echo "Alter ROLE rma WITH   login;" >> /tmp/t.sql
	 echo "CREATE DATABASE rma OWNER = rma ;" >> /tmp/t.sql
	 su postgres -c  psql </tmp/t.sql
	  	 
	 	 
 fi
 	