#!/bin/sh

 for path in $*
  do
   path=`echo $path | sed "/[.][.]/s///g"` 
   path=`echo $path | sed "/\/$/s///"`
   path=`echo $path | sed "/^\/home\/app/s///"`
   echo Path $path
   ls /home/app/`dirname $path`
     if [ -h  /home/app/$path ] 
      then
  		dest=`ls -la /home/app/$path |cut -f2 -d'>'`
  		echo dest = $dest
  		chmod -R gu+rw $dest
     elif test -d  /home/app/$path 
  	  then
  		echo chmod  775 /home/app/$path
   		chmod  775 /home/app/$path   
     elif test ! -f /home/app/$path 
  	  then
  		echo mkdir -p  `dirname /home/app/$path`
   		mkdir -p  `dirname /home/app/$path`
   		ls  -la /home/app/$path 
   		touch  /home/app/$path 
 	 fi
   chown $ContUser /home/app/$path
   chmod  ug+rw /home/app/$path   
done    
        