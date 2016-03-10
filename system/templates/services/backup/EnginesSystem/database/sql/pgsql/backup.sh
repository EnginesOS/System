#!/bin/bash
export  PGPASSWORD='$dbpasswd'

pg_dump  -h $dbhost -Fc -U $dbuser  $dbname 2>/tmp/pg_sqldump.errs
if test $? -ne 0
 then 
 	cat  /tmp/pg_sqldump.errs
 	exit -1
 fi
 
 exit 0