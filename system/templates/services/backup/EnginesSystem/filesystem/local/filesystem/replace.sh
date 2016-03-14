#!/bin/bash
Archive=/big_tmp/archive
cd /home/fs
dirname=`basename $VOLDIR `
cp -rp $VOLDIR /big_tmp/$dirname.bak
 rm -r $VOLDIR/*
 
if test -f  /tmp/extract.err
 then
rm /tmp/extract.err
fi

cat - > $Archive
cd /
type=`file -i $Archive |grep application/gzip`
if test $? -eq 0
 then
echo Gzip
 cat  $Archive  | gzip -d  | tar -xpf  -  2>/tmp/extract.err

echo xxx
echo "cat $Archive | gzip -d | tar -xpf  -"

else
cat $Archive | tar -xpf  - 2>/tmp/extract.err

  fi
        if test $? -eq 0
          then
           rm  $Archive
           rm -r /big_tmp/$dirname.bak
           exit 0
           else
            rm -r $VOLDIR/*
            cp -rp /big_tmp/$dirname.bak/. $VOLDIR
             rm -r /big_tmp/$dirname.bak
            cat  /tmp/extract.err
            echo  Rolled back >&2
         fi
