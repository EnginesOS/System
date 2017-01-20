#!/bin/sh
cd /home/app
    for mod in $*
     do    
   		npm  install $mod
     done