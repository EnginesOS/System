#!/bin/bash

for $path in $0
 do
	dir=`dirname path`
	mkdir -p /home/$dir

 		if [ ! -f /home/$path
  		   then 
    		touch  /home/$path
    	fi
    
	mkdir -p $VOLDIR/$dir
	mv /home/$path /$VOLDIR/$dir
	ln -s  $VOLDIR/$path /home/$path
done