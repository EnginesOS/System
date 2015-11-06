#!/bin/bash


for path in `cat $VOLDIR/.dynamic_persistance`
      do
      path=`echo $path | sed "/[.][.]/s///g" | sed "/[&;><|]/s///g"` 
    
     if ! test -e /home/app/$path
      then
 			path=`echo $path | sed "/\/$/s///"`
 			echo 	ln -s "$VOLDIR/$path" "/home/app/$path"
			ln -s "$VOLDIR/$path" "/home/app/$path"
		fi	
	done
	
	touch /home/app/.dynamic_persistance_restored