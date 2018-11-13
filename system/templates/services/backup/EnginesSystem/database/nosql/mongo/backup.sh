#!/bin/bash
. /home/engines/functions/params_to_env.sh
params_to_env
cd /tmp
 if test -z $dbname
  then
   echo dbname cant be nill
   exit -1
  fi 
mongodump  -h mongo --password $dbpasswd -u $dbuser -d  $dbname  
tar -cpf - dump |gzip -c
rm -r dump
exit 0