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
   destination=$dest_path/$file 
   echo $volume maps to $dest_path, for persistent file $file
   if ! test -d `dirname $destination`
    then
    echo "mkdir -p $destination"
    	mkdir -p $destination
    fi
    echo cp -np /home/$file $destination 
 	cp -np /home/$file $destination 
 	rm /home/$file
 	echo "ln -s $dest_path/$file /home/$file"
 	ln -s $dest_path/$file /home/$file 
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