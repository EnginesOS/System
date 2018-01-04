#!/bin/bash
set
for path in $*
  do
 Volume=`echo $path |cut -f1 -d:`
 VOLDIR=`cat /home/fs_src/volumes/$Volume`
 echo $VOLDIR |grep /home/fs/ >/dev/null
 if test $? -ne 0
  then
  VOLDIR=/home/fs/$VOLDIR
 fi
 path=`echo $path |cut -f2 -d:`
   echo $path |grep ^/usr/local/ >/dev/null
    if test $? -eq 0
     then
      path=`echo $path | sed "/\/usr\/local\//s///"`
      prefix=/usr/local/
     else
      prefix=/home/
    fi 
  echo Prefix: $prefix
  path=`echo $path | sed "/[.][.]/s///g"` 
  echo Path: $path
  path=`echo $path | sed "/\/$/s///"`
  dirname=`dirname "$path" `
  mkdir -p "$VOLDIR/$dirname"
  echo mkdir -p "$VOLDIR/$dirname"
   	 if [ ! -d "$prefix/$path" ]
      then 
        mkdir -p "$prefix/$path" 
   		echo Make Dir: mkdir -p "$prefix/$path" 
   	 fi
  mv "$prefix/$path" "$VOLDIR/$dirname" 
  echo "mv $prefix / $path" "$VOLDIR / $dirname" 
  ln -s "$VOLDIR/$path" "$prefix/$path"
  echo ln -s "$VOLDIR/$path" "$prefix/$path"
done