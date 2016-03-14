#!/bin/bash

Archive=/tmp/archive 
cd /tmp
cat - > $Archive

type=`file -i $Archive |grep application/gzip`
if test $? -eq 0
 then
  extract="|gzip -d "
  fi
  
	cat $Archive $extract | mysql -h $dbhost -u $dbuser --password $dbpasswd $dbname 2> /tmp/extract.err
	if test $? -eq 0
	  then
	   rm  $Archive
	  
	   exit 0
	   else
	
	    cat  tmp/extract.err
	    echo  Rolled back >&2
	 fi 




