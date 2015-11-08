#!/bin/bash



	#$* some/were/to/path
	#
	# mkdir $voldir/some/were/to/path
	#dirname = /some/were/to/
	# mv /home/$path $VOLDIR/$dirname
	#ln -s $voldir/$dirname /home/some/were/to/path
	for path in $*
      do
      path=`echo $path | sed "/[.][.]/s///g"` 
      echo $path
 path=`echo $path | sed "/\/$/s///"`
		dirname=`dirname "$path" `
		mkdir -p "$VOLDIR/$dirname"
		echo mkdir -p "$VOLDIR/$dirname"
		touch  "$VOLDIR/at1"
   			if [ ! -d "/home/$path" ]
     			then 
       			    mkdir -p "/home/$path" 
   					echo mkdir -p "/home/$path" 
   			fi

		mv "/home/$path" "$VOLDIR/$dirname" 
	echo "/home/$path" "$VOLDIR/$dirname" 
		ln -s "$VOLDIR/$path" "/home/$path"
		echo ln -s "$VOLDIR/$path" "/home/$path"
	done