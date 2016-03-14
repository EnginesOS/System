#!/bin/bash
export  PGPASSWORD=$dbpasswd

pg_dump  -h $dbhost -Fc -U $dbuser  $dbname |gzip -c 2>/tmp/pg_sqldump.errs
export  PGPASSWORD=''
if test $? -ne 0
 then 
 	cat  /tmp/pg_sqldump.errs
 	exit -1
 fi
 
 exit 0