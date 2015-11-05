#!/bin/bash


source_url=$1
package_name=$2
extraction_command=$3
destination=$4
path_to_extracted=$5
cd /tmp

echo Source URL $source_url 
echo Extract with $extraction_command from  $package_name to $path_to_extracted 
echo Install to $destination
 
 if test -z "$path_to_extracted"
  then
  	path_to_extracted=./app
 fi

 if test "$extraction_command" = 'git'
  then
   echo git clone $source_url --depth 1 "./$path_to_extracted"
  	git clone $source_url --depth 1 "./$path_to_extracted"
  	elif  test -z "$extraction_command" 
  	 then
  	 echo wget -O $package_name $source_url
  	  path_to_extracted=$package_name 
  else
    echo wget -O $package_name $source_url
	wget -O $package_name $source_url
	$extraction_command $package_name
  fi
  
 destination=`echo $destination | sed "/\/$/s///"`
 
 if test ! -d "./$path_to_extracted"
   then 
   		mkdir -p $destination
 	fi
 echo "./$path_to_extracted" $destination
 mv "./$path_to_extracted" $destination