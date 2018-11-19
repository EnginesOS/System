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

cat - > $Archive
type=`file -i $Archive |grep application/gzip`
cd /

if test $? -eq 0
 then
  cat  $Archive  | gzip -d  | tar -xpf - 
else
  cat $Archive | tar -xpf -
fi
if test $? -eq 0
 then
   rm  $Archive
   rm -r /tmp/big/$dirname.bak
   exit 0
else
   rm -r $engine_path/*
   cp -rp /tmp/big/$dirname.bak/. $engine_path
   cat  /tmp/extract.err
   echo  Rolled back >&2
fi
