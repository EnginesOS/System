#!/bin/bash
cat /home/fs/vol_file_maps
echo ls -l fs
ls -l /home/fs
echo ls home
ls -l /home
echo ls -l fs_src
ls -l /home/fs_src


for file  in `cat /home/fs/vol_file_maps | awk '{ print $1}'`
 do 
   volume=`grep "$file " /home/fs/vol_file_maps| awk '{print $2}'`	
   dest_path=`cat /home/volumes/$volume`
   ln_destination=$dest_path/$file
    destination=/home/fs/$file
   echo $volume maps to $dest_path, for persistent file $file
   if ! test -d `dirname $destination`
    then
    echo "mkdir -p $destination"
    	mkdir -p `dirname $destination`
    fi
    if ! test -f /home/$file
     then
      touch /home/$file
    fi
    echo cp -np /home/$file $destination 
 	cp -np /home/$file $destination 
 	rm /home/$file
 	echo "ln -s $ln_destination /home/$file"
 	ln -s $ln_destination /home/$file 
 done
 
#set
#for path in $*
# do
#Volume=`echo $path |cut -f1 -d:`
# VOLDIR=`cat /home/fs/volumes/$Volume`
#echo $Volume to $VOLDIR
# echo $VOLDIR |grep /home/fs/ >/dev/null
# if test $? -ne 0
#  then
#  VOLDIR=/home/fs/$VOLDIR
# fi
# path=`echo $path |cut -f2 -d:`
#   path=`echo $path | sed "/[.][.]/s///g"` 
#   echo $path
#   path=`echo $path | sed "/\/$/s///"`
#   dir=`dirname $path`
#   mkdir -p /home/$dir
#   echo "mkdir -p /home/$dir"
#   echo file $path is in $dir
# 	if [ ! -f /home/$path ]
#  	  then 
#  		echo "touch  /home/$path"
#    	touch  /home/$path
#     fi  	
#  echo mkdir -p $VOLDIR/$dir
#  mkdir -p $VOLDIR/$dir
#  echo "mv /home/$path /$VOLDIR/$dir"
#  mv /home/$path /$VOLDIR/$dir	
#  echo "ln -s  $VOLDIR/$path /home/$path"
#  ln -s  $VOLDIR/$path /home/$path
#done