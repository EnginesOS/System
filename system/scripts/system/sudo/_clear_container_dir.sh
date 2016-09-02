#!/bin/bash

if test $# -gt 0
  then
  if test -d $1
   then
	rm -r /opt/engines/run/$1
  fi
fi 
