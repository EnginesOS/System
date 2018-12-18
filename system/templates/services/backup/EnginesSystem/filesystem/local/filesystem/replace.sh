#!/bin/sh


if ! test -d /tmp/big/
 then
   mkdir -p /tmp/big/
fi 

if test -z $engine_path `
 echo 'engine_path is required` >&2
 exit -1
fi
Archive=/tmp/big/archive
cd /home/fs
dirname=`basename $engine_path `

cp -rp $engine_path /tmp/big/$dirname.bak
rm -r $engine_path/*
if test -f  /tmp/extract.err
 then
rm /tmp/extract.err
fi

cat - > $Archive
cd /
type=`file -i $Archive |grep application/gzip`
if test $? -eq 0
 then
  cat  $Archive  | gzip -d  | tar -xpf  -  
else
 cat $Archive | tar -xpf  - 
fi
if test $? -eq 0
 then
   rm  $Archive
   rm -r /tmp/big/$dirname.bak
   exit 0
else
   rm -r $engine_path/*
   cp -rp /tmp/big/$dirname.bak/. $engine_path
   rm -r /tmp/big/$dirname.bak   
   echo  Rolled back >&2
   exit -1
fi
