#!/bin/bash
Archive=/big_tmp/archive 
cd /home/fs
dirname=`basename $VOLDIR `
cp -rp $VOLDIR /big_tmp/$dirname.bak
rm -r $VOLDIR/*
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
	   rm -r /big_tmp/$dirname.bak
	   exit 0
	   else
	    rm -r $VOLDIR
	    mv /big_tmp/$dirname.bak $VOLDIR
	    cat  /tmp/extract.err
	    echo  Rolled back >&2
	 fi 

