#!/bin/bash
cat /home/fs/vol_dir_maps
echo ls -l fs
ls -l /home/fs
echo ls -l fs_src
ls -l /home/fs_src
echo ls home
ls -l /home

for dir  in `cat /home/fs/vol_dir_maps | awk '{ print $1}'`
 do 
   volume=`grep "$dir " /home/fs/vol_dir_maps| awk '{print $2}'`	
   dest_path=`cat /home/volumes/$volume`
   ln_destination=$dest_path/$dir 
    destination=/home/fs_src/$dir
    
   echo $volume maps to $dest_path, for persistent dir $dir
    
   if ! test -d `dirname $destination`
    then
    	echo "mkdir -p $destination"
    	mkdir -p `dirname $destination`
    fi
    echo "cp -rnp /home/$file $destination "
 	cp -rnp /home/$file $destination 
 	rm -r /home/$dir 
 	echo "ln -s $ln_destination /home/$dir"
 	ln -s $destination /home/$dir
 done
#set
#
#for path in $*
#  do
# Volume=`echo $path |cut -f1 -d:`
# VOLDIR=`cat /home/fs/volumes/$Volume`
# echo $VOLDIR |grep /home/fs/ >/dev/null
# if test $? -ne 0
#  then
#  VOLDIR=/home/fs/$VOLDIR
# fi
# path=`echo $path |cut -f2 -d:`
#   echo $path |grep ^/usr/local/ >/dev/null
#    if test $? -eq 0
#     then
#      path=`echo $path | sed "/\/usr\/local\//s///"`
#      prefix=/usr/local/
#     else
#      prefix=/home/
#    fi 
#  echo Prefix: $prefix
#  path=`echo $path | sed "/[.][.]/s///g"` 
#  echo Path: $path
#  path=`echo $path | sed "/\/$/s///"`
#  dirname=`dirname "$path" `
#  mkdir -p "$VOLDIR/$dirname"
#  echo mkdir -p "$VOLDIR/$dirname"
#   	 if [ ! -d "$prefix/$path" ]
#      then 
#        mkdir -p "$prefix/$path" 
#   		echo Make Dir: mkdir -p "$prefix/$path" 
#   	 fi
#  mv "$prefix/$path" "$VOLDIR/$dirname" 
#  echo "mv $prefix / $path" "$VOLDIR / $dirname" 
#  ln -s "$VOLDIR/$path" "$prefix/$path"
#  echo ln -s "$VOLDIR/$path" "$prefix/$path"
#done