#!/bin/bash

echo PACKAGE_INSTALLER_RUN $PACKAGE_INSTALLER_RUN
 
if [ ! -d /home/app ]
 then 
   mkdir -p /home/app 
  fi
  
 mkdir -p /home/fs ; mkdir -p /home/fs/local 
 chown -R $ContUser /home/app /home/fs /home/fs/local   

 
#echo PACKAGE_INSTALLER_RUN "$PACKAGE_INSTALLER_RUN"
# 
#
#dirs=/home/fs /home/fs/local  /home/app
#
#for fir in $dirs
# do
#  if [ ! -d $dir ]
#   then
#   	 mkdir -p $dir
#   fi
#   chown -R $ContUser $dir   
# done
 
  