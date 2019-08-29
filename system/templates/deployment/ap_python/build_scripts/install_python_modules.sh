#!/bin/sh
    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     python${python_version} -m pip install --upgrade $mod --user
     echo python${python_version} -m pip install --upgrade $mod --user
     done