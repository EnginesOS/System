#!/bin/bash


for directory in $*
 do
   directory=`echo $directory | sed "/[.][.]/s///g"` 
   echo not .. $directory
   directory=`echo $directory | sed "/^\/home\/app/s///"`
   echo no prefix $directory
   directory=`echo $directory | sed "/\/$/s///"`
   echo no suffix $directory
    if [ -h  /home/app/$directory ] 
     then 
       dest=`ls -la /home/app/$directory |cut -f2 -d'>'`
       echo " chmod -R gu+rw $dest ;chgrp $data_gid -R $dest"
       ls -la $dest
      #chmod -R gu+rw $dest
      #chgrp $data_gid -R $dest
    elif [ ! -d /home/app/$directory ] 
      then 
        echo " mkdir  -p /home/app/$directory "
        echo "  chown $data_uid  /home/app/$directory "
        echo "   chmod -R gu+rw /home/app/$directory "       
        mkdir  -p /home/app/$directory
        chown $data_uid  /home/app/$directory
        chmod -R gu+rw /home/app/$directory 
     else
        echo "   chmod -R gu+rw /home/app/$directory  ; chgrp $data_gid -R /home/app/$directory" 
        chgrp $data_gid -R /home/app/$directory
        chmod -R gu+rw /home/app/$directory  
    fi   
  dirs=`find /home/app/$directory -type d -print0`
    if ! test -z "$dirs" 
      then
        find /home/app/$directory -type d -print0 | xargs -0 chmod 775
    fi        
  files=`find /home/app/$directory -type f -print0`
    if ! test -z "$files" 
      then
        find /home/app/$directory -type f -print0 | xargs -0 chmod 664
    fi
       
done
