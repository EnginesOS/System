#!/bin/bash
cd /tmp
mongodump  -h mongo --password $dbpasswd -u $dbuser -d  $dbname  2>/tmp/mysqldump.errs
if test $? -ne 0
 then 
 	cat  /tmp/mysqldump.errs
 	exit -1
 fi
tar -cpf - dump |gzip -c
rm -r dump
exit 0