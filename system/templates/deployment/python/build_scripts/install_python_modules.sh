#!/bin/sh
    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     python${python_ver} -m pip install --upgrade $mod
     done