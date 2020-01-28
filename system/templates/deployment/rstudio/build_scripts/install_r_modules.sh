#!/bin/sh
#could be dynamic
for mod in $*
  do
  R -e "install.packages('"$mod"')" 
done


  
