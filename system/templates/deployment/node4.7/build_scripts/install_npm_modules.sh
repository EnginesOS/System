#!/bin/sh
cd /home/app
for mod in $*
  do    
   sudo su $ContUser sh -c "npm  install -g $mod"
 done
