#!/bin/sh
cd /home/app
    for mod in $*
     do    
   		npm  install $mod
     done
#Fix damage while root      
   chown $ContUser -R  /home/home_dir/.npm