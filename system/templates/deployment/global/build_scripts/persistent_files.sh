#!/bin/bash
set
for path in $*
 do
Volume=`echo $path |cut -f1 -d:`
 VOLDIR=`cat /home/fs/volumes/$Volume`
echo $Volume to $VOLDIR
 echo $VOLDIR |grep /home/fs/ >/dev/null
 if test $? -ne 0
  then
  VOLDIR=/home/fs/$VOLDIR
 fi
 path=`echo $path |cut -f2 -d:`
   path=`echo $path | sed "/[.][.]/s///g"` 
   echo $path
   path=`echo $path | sed "/\/$/s///"`
   dir=`dirname $path`
   mkdir -p /home/$dir
   echo "mkdir -p /home/$dir"
   echo file $path is in $dir
 	if [ ! -f /home/$path ]
  	  then 
  		echo "touch  /home/$path"
    	touch  /home/$path
     fi  	
  echo mkdir -p $VOLDIR/$dir
  mkdir -p $VOLDIR/$dir
  echo "mv /home/$path /$VOLDIR/$dir"
  mv /home/$path /$VOLDIR/$dir	
  echo "ln -s  $VOLDIR/$path /home/$path"
  ln -s  $VOLDIR/$path /home/$path
done