#!/bin/sh

for mod in $*
  do
  R -e "install.packages('"$mod"')" 
done


  
