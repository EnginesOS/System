#!/bin/bash

cd /var/lib/engines

if ! test -d services
 then
  mkdir services
  chown engines.containers services
fi



for service in auth email imap mgmt redis syslog ldap
 mv $service services
fi
 
mv mongo services/mongo_server
mv pqsql services/pgsql_server
mv mysql services/mysql_server