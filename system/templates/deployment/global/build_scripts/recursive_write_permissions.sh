#!/bin/bash
data_uid=$1
shift
for directory in $*
 do
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
             for dir in `find  /home/app/$directory -type d  `
               do
                  adir=`echo $dir | sed "/ /s//_+_/g" |grep -v _+_` 
                    if test -n $adir
                        then
                              dirs=`echo $dirs $adir`
                        fi
               done
         if test -n '$dirs' 
              then
              chmod gu+x $dirs 
        fi
        fi
        
        done
