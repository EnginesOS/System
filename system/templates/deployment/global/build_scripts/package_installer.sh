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
  else
    echo wget -O $package_name $source_url
	wget -O $package_name $source_url
	echo su $ContUser -c $extraction_command $package_name
	su $CountUser $extraction_command $package_name
  fi

 if test ! -d "./$path_to_extracted"
   then 
   		mkdir -p $destination
 	fi
 echo "./$path_to_extracted" $destination
 mv "./$path_to_extracted" $destination