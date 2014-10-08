#!/bin/bash

chown -R postgres /var/lib/postgresql
chown postgres -R /var/log/postgresql/


 echo listen_addresses = '*' >> /etc/postgresql/9.3/postgresql.conf
 echo "host all all 172.17.42.0/16  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
 
 service postgresql restart