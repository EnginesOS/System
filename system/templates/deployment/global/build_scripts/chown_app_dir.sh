#!/bin/bash

echo PACKAGE_INSTALLER_RUN "$PACKAGE_INSTALLER_RUN"
 

dirs=/home/fs /home/fs/local  /home/app

for fir in $dirs
 do
  if [ ! -d $dir ]
   then
   	 mkdir -p $dir
   fi
   chown -R $ContUser $dir   
 done


  