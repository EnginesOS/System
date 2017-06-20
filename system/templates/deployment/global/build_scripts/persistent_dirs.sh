#!/bin/bash

for path in $*
  do
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