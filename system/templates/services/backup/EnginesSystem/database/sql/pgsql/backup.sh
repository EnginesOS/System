#!/bin/sh

export  PGPASSWORD=$dbpasswd
 if test -z $dbname
  then
   echo dbname cant be nill
   exit -1
  fi 
pg_dump  -h $dbhost -Fc -U $dbuser  $dbname 2> /dev/null |gzip -c 