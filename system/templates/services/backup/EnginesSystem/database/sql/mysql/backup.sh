#!/bin/sh

 
 if test -z $dbname
  then
   echo dbname cant be nill
   exit -1
  fi 
mysqldump -h $dbhost -u $dbuser --password=$dbpasswd $dbname