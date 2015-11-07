#!/bin/sh
    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     php5enmod  $mod
     done