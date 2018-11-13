#!/bin/bash
. /home/engines/functions/params_to_env.sh
params_to_env
export  PGPASSWORD=$dbpasswd
 if test -z $dbname
  then
   echo dbname cant be nill
   exit -1
  fi 
pg_dump  -h $dbhost -Fc -U $dbuser  $dbname |gzip -c 