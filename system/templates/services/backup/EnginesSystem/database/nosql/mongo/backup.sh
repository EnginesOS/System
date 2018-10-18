#!/bin/bash
. /home/engines/functions/params_to_env.sh
params_to_env
cd /tmp
mongodump  -h mongo --password $dbpasswd -u $dbuser -d  $dbname  2>/tmp/mongodump.errs
if test $? -ne 0
 then 
 	cat  /tmp/mongodump.errs  >&2
 	exit -1
 fi
tar -cpf - dump |gzip -c
rm -r dump
exit 0