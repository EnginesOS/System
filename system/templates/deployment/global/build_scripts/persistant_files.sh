#!/bin/bash

for path in $*
 do
 path=`echo $path | sed "/../s///g"` 
 echo $path
  path=`echo $path | sed "/\/$/s///"`
	dir=`dirname $path`
	mkdir -p /home/$dir
	echo "-p /home/$dir"
echo file $path is in $dir
 
 		if [ ! -f /home/$path ]
  		   then 
    		touch  /home/$path
    	fi
    echo mkdir -p $VOLDIR/$dir
	mkdir -p $VOLDIR/$dir
	echo "mv /home/$path /$VOLDIR/$dir"
	mv /home/$path /$VOLDIR/$dir
	echo "ln -s  $VOLDIR/$path /home/$path"
	ln -s  $VOLDIR/$path /home/$path
done