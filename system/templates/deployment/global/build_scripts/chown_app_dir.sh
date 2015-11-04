#!/bin/bash

ContUser=$1

if [ ! -d /home/app ]
 then 
   mkdir -p /home/app 
  fi
  
 mkdir -p /home/fs ; mkdir -p /home/fs/local 
 chown -R $ContUser /home/app /home/fs /home/fs/local    