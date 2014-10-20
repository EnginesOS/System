#!/bin/bash
pass="pass"

 	#Run First Time on persistent DB
 	
 if ! test -f /var/lib/postgresql/conf
 then

	cp -rp /var/lib/postgresql_firstrun/* /var/lib/postgresql/ 

	chown -R postgres /var/lib/postgresql
	mkdir -p /var/log/postgresql
	chown postgres -R /var/log/postgresql
	
 	postgres  service postgresql start
 
 	touch /var/lib/postgresql/conf
	 echo "ALTER ROLE postgres WITH ENCRYPTED PASSWORD 'pass'; " > /tmp/t.sql
	  echo "Add ROLE rma WITH ENCRYPTED PASSWORD 'pass'; " >> /tmp/t.sql
	  echo "Alter ROLE rma WITH superuser;" >> /tmp/t.sql
	   echo "Alter ROLE rma WITH login;" >> /tmp/t.sql
	 echo "  /usr/bin/psql " > /tmp/t.sh
	 chmod +x /tmp/t.sh
	  su postgres -c  /tmp/t.sh </tmp/t.sql
	  su postgres creatdb rma
	  
	  rm /tmp/t.sh
	  rm /tmp/t.sql
	 
 fi
 	