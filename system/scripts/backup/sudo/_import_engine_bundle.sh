#!/bin/sh

tar -xpf - 
pwd=`pwd`
app=`basename $pwd`

cp -rp opt/engines/run/apps/$app /opt/engines/run/apps/
