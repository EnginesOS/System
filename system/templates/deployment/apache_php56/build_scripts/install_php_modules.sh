#!/bin/sh
#could be dynamic

    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     phpenmod  $mod
     done