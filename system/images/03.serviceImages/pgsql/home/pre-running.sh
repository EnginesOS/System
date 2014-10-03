#!/bin/bash

chown -R postgres /var/lib/postgresql


 echo listen_addresses = '*' >> /etc/postgresql/9.1/postgresql.conf
 echo "host all all 172.17.42.0/16  md5" >> /etc/postgresql/9.1/main/pg_hba.conf
 
 service postgresql restart