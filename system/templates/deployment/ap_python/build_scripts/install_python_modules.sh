#!/bin/sh

virtualenv --system-site-packages --python=python3.7 /home/app/venv
. /home/app/venv/bin/activate

    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     python${python_version} -m pip install --upgrade $mod --user
     echo python${python_version} -m pip install --upgrade $mod --user
     done