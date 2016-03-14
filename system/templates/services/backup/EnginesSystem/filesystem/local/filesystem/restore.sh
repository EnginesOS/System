#!/bin/bash
Archive=/tmp/archive 
cd /home/fs
dirname=`basename $VOLDIR `
cp -rp $VOLDIR /home/fs/$dirname.bak

cat - > $Archive
cd /
type=`file -i $Archive |grep application/gzip`
if test $? -eq 0
 then
  extract="|gzip -d "
  fi
  
	cat $Archive $extract | tar -xpf - 2>/tmp/extract.err
	if test $? -eq 0
	  then
	   rm  $Archive
	   rm /home/fs/$dirname.bak
	   exit 0
	   else
	    rm -r $VOLDIR
	    mv /home/fs/$dirname.bak $VOLDIR
	    cat  /tmp/extract.err
	    echo  Rolled back >&2
	 fi 

