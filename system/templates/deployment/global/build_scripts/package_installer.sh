#!/bin/bash


source_url=$1
package_name=$2
extraction_command=$3
destination=$4
path_to_extracted=$5
cd /tmp

 if test -z $path_to_extracted
  then
  	path_to_extracted=./app
 fi

 if test $extraction_command = 'git'
  then
  	git clone $source_url --depth 1 ./$path_to_extracted
  else
	wget -O $package_name $source_url
	su $CountUser $extraction_command $package_name
  fi

 if test ! -d ./$path_to_extracted
   then 
   		mkdir -p $destination
 	fi
 
 mv ./$path_to_extracted $destination