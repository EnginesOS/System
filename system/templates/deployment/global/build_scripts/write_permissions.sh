#!/bin/bash



 for path in $*
  do
    if [ ! -f /home/app/$path ]
  	  then
   		mkdir -p  `dirname /home/app/$path`
   		touch  /home/app/$path 
 	   fi
	chown $ContUser /home/app/$path
    chmod  775 /home/app/$path   
  done    
        