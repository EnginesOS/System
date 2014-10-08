#!/bin/bash
#have to restart for settings to take on first run
 mkdir -p /var/log/postgresql
 	 chown -R postgres /var/lib/postgresql
	 chown postgres -R /var/log/postgresql
	echo "listen_addresses = '*'" >> /etc/postgresql/9.[0-9]/main/postgresql.conf
 	echo "host all all 172.17.42.0/16  md5" >> /etc/postgresql/9.[0-9]/main/pg_hba.conf
 	
 service postgresql restart