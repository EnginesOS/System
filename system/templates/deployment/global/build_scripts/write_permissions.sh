#!/bin/bash




 for path in $*
  do
  path=`echo $path | sed "/\/$/s///"`
  if [ -h  /home/app/$path ] 
  		dest=`ls -la /home/app/$path |cut -f2 -d'>'`
         chmod -R gu+rw $dest
  elif [ -d  /home/app/$path ] 
  	  then
   		chmod  775 /home/app/$path   
   elif [ ! -f /home/app/$path ]
  	  then
   		mkdir -p  `dirname /home/app/$path`
   		touch  /home/app/$path 
 	   fi
	chown $ContUser /home/app/$path
    chmod  ug+rw /home/app/$path   
  done    
        