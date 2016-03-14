#!/bin/bash
script=$0
Script_Dir=`dirname $0`
Archive=/big_tmp/archive 
cd /tmp
cat - > $Archive

$Script_Dir/backup.sh > /big_tmp/backup.sql
  
cat $Script_Dir/drop_tables.sql | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname 2> /tmp/extract.err
  
	

type=`file -i $Archive |grep application/gzip`
if test $? -eq 0
 then
 cat $Archive| gzip -d| mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname 2> /tmp/extract.err
 else
 cat $Archive $extract | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname 2> /tmp/extract.err
  fi
 
	if test $? -eq 0
	  then
	   rm  $Archive
	  rm /big_tmp/backup.sql
	   exit 0
	   else
	    cat /big_tmp/backup.sql| mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname 2> /tmp/roll_back.err
	    cat  /tmp/extract.err
	    cat /tmp/roll_back.err
	    echo  Rolled back >&2
	    rm /big_tmp/backup.sql $Archive
	 fi 




