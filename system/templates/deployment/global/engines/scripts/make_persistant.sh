#!/bin/bash


	for path in $*
      do
      path=`echo $path | sed "/[.][.]/s///g" | sed "/[&;><]/s///g"` 
      if test -d/home/app/$path
       then
 			path=`echo $path | sed "/\/$/s///"`
			dirname=`dirname "$path" `
			mkdir -p "$VOLDIR/$dirname"
			cp -rp "/home/app/$path" "$VOLDIR/$dirname"
			rm -rf  /home/app/$path"
			ln -s "$VOLDIR/$path" "/home/app/$path"
		elif if test -f $path		
			dir=`dirname $path`
    		echo mkdir -p $VOLDIR/$dir
			mkdir -p $VOLDIR/$dir
			echo "mv /home/app/$path /$VOLDIR/$dir"
			cp -rp /home/app/$path /$VOLDIR/$dir
			rm -rf  /home/app/$path"
			echo "ln -s  $VOLDIR/$path /home/app/$path"
			ln -s  $VOLDIR/$path /home/app/$path
		fi
	done