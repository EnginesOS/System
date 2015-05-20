#!/bin/bash

for dir in `ls `
do
cd $dir
gitname=`echo $dir |sed "/[a-z].*_/s///"`
echo +++Processing+++ $gitname
	
	#git remote rm origin
	#git remote add origin git@github.com:EnginesBlueprints/${gitname}.git
	git add -A
	git commit -m "$1"
	git push -u origin master
	cd ..
done
