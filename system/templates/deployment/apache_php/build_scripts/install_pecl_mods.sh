#!/bin/bash



    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     pecl install $mod
     done
   
  
