#!/bin/sh
#could be dynamic
cd /home/home_dir/.npm
for mod in $*
  do    
   sudo su $ContUser sh -c "npm  install -g $mod"
done