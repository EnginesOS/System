#!/bin/bash

/home/engines/scripts/make_persistant.sh *$

for path in *$
 do
 	chmod ugo-w "$VOLDIR/$path" "/home/app/$path"
 done


