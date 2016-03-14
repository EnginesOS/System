#!/bin/bash
 
mysqldump -h $dbhost -u $dbuser --password=$dbpasswd $dbname |gzip -c 2>/tmp/mysqldump.errs
if test $? -ne 0
 then 
 	cat  /tmp/mysqldump.errs
 	exit -1
 fi
 
 exit 0