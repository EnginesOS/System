#!/bin/sh
#could be dynamic
for mod in $*
  do
   luarocks install $mod
done


  
