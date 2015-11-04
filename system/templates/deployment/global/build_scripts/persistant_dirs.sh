#!/bin/bash

VOLDIR=$1
shift

	#$* some/were/to/path
	#
	# mkdir $voldir/some/were/to/path
	#dirname = /some/were/to/
	# mv /home/$path $VOLDIR/$dirname
	#ln -s $voldir/$dirname /home/some/were/to/path
	for path in $*
      do

		dirname=`dirname "$path" `
		mkdir -p "$VOLDIR/$dirname"
   			if [ ! -d "/home/$path" ]
     			then 
       			    mkdir -p "/home/$path" 
   			fi

		mv "/home/$path" "$VOLDIR/$dirname" 
		ln -s "$VOLDIR/$path" "/home/$path"
	done