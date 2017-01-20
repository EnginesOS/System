#!/bin/sh
cd /home/app
    for mod in $*
     do    
   		su  $ContUser npm  install $mod
     done