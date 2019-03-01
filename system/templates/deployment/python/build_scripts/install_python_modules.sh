#!/bin/sh
    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     python${python_version} -m pip install --upgrade $mod
     echo python${python_version} -m pip install --upgrade $mod
     done