#!/bin/bash

Archive=/tmp/big/archive 
cd /tmp
mkdir -p /tmp/big/
cat - > $Archive



type=`file -i $Archive |grep application/gzip`
if test $? -eq 0
 then
 cat $Archive| gzip -d| env  PGPASSWORD=$dbpasswd psql   -h $dbhost -U $dbuser  $dbname  2> /tmp/extract.err
 else
 cat $Archive | env  PGPASSWORD=$dbpasswd psql   -h $dbhost -U $dbuser  $dbname  2> /tmp/extract.err
  fi
	
	if test $? -eq 0
	  then
	   rm  $Archive 
	   rm  /tmp/extract.err
	   exit 0
	   else
	
	    cat  /tmp/extract.err
	    echo  Rolled back >&2
	    rm  $Archive
	    rm  /tmp/extract.err
	 fi 




