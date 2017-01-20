#!/bin/sh
cd /home/app
    for mod in $*
     do    
   		su -l $ContUser npm  install $mod
     done