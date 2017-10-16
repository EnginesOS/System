#!/bin/bash

cd /var/lib/engines

if ! test -d services
 then
  mkdir services
  chown engines.containers services
fi

rmdir services/syslog/rmt
rmdir services/

for service in auth cert_auth email imap mgmt redis syslog ldap
 do
 mv $service services
done
 
mv mongo services/mongo_server
mv pgsql services/pgsql_server
mv mysql services/mysql_server