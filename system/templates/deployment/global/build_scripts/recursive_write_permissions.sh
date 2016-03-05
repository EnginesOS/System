#!/bin/bash


for directory in $*
 do
 directory=`echo $directory | sed "/[.][.]/s///g"` 
 echo $directory
 	directory=`echo $directory | sed "/\/$/s///"`
          if [ -h  /home/app/$directory ] 
            then 
            dest=`ls -la /home/app/$directory |cut -f2 -d'>'`
            chmod -R gu+rw $dest
          elif [ ! -d /home/app/$directory ] 
            then 
              mkdir  -p /home/app/$directory
             chown $data_uid  /home/app/$directory
             chmod -R gu+rw /home/app/$directory 
          else
          chmod -R gu+rw /home/app/$directory
          
        fi
        
        dirs=`find /home/app/$directory -type d -print0`
        if ! test -z "$dirs" 
          then
         	echo $dirs | xargs -0 chmod 755
         fi
         
        files=`find /home/app/$directory -type f -print0`
        if ! test -z "$files" 
          then
         	echo $files | xargs -0 chmod 644
         fi
       
        done
