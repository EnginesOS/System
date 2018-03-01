#!/bin/sh
cd /home/app
for mod in $*
  do    
   sudo -n su $ContUser sh -c "npm  install -g $mod"
 done
