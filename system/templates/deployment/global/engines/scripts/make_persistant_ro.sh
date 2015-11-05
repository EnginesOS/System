#!/bin/bash

/home/engines/scripts/make_persistant.sh $*

for target in $*
 do
 /home/engines/scripts/make_persistant.sh $target
 	chmod ugo-w "$VOLDIR/$target" "/home/app/$target"
 done


