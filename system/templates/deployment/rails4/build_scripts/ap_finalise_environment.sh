#!/bin/bash

for dir in /home/app/tmp/ /home/app/public/cache/ /home/app/public/assets /run/apache2
 do
	if ! test -d $dir
	 then
		if ! test -h $dir
		 then
			mkdir -p $dir
		fi
	fi
done 
	
chown www-data.$data_gid -R /home/app/public
chown www-data.$data_gid -R /home/app/tmp/ /run/apache2

mkdir -p log
chmod -R g+w  log

if test -d db
  then 
   chmod -R g+w  db
 fi