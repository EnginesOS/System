#!/bin/bash


source_url=$1
package_name=$2
extraction_command=$3
destination=$4
path_to_extracted=$5
cd /tmp

export PACKAGE_INSTALLER_RUN=yes
source_url=`echo $source_url | sed "/[;&]/s///g"` 
package_name=`echo $package_name | sed "/[;&]/s///g"` 
extraction_command=`echo $extraction_command | sed "/[;&]/s///g"` 
package_name=`echo $package_name | sed "/[.][.]/s///g"` 
destination=`echo $destination | sed "/[.][.]/s///g"` 
path_to_extracted=`echo $path_to_extracted | sed "/[.][.][ ]/s///g"` 
# 
 
   
echo Source URL $source_url 
echo Extract with $extraction_command from  $package_name to $path_to_extracted 
echo Install to $destination


 if test "$extraction_command" = 'git'
  then
   echo git clone $source_url --depth 1 "./$path_to_extracted"
  	git clone $source_url --depth 1 "./$path_to_extracted"
  	elif  test -z "$extraction_command" 
  	 then
  	  wget -O $package_name $source_url
  	  path_to_extracted=$package_name 
  else
    #echo wget -O $package_name $source_url
	wget -O $package_name $source_url
	#echo "$path_to_extracted"
	if test -z "$path_to_extracted" -o "$path_to_extracted" = './' -o "$path_to_extracted" = '/'
		then
				path_to_extracted=app
				mkdir /tmp/app
				#pwd
				#echo $path_to_extracted
				cd /tmp/app
				#pwd
				#echo "$extraction_command ../$package_name"				
				$extraction_command ../$package_name
				cd /tmp
				#pwd
		else
				#echo "$extraction_command $package_name"
				$extraction_command $package_name
	fi	
  fi
  
 destination=`echo $destination | sed "/\/$/s///"`
 if ! test "/home/app" == $destination  -o "app" == $destination  -o "/app" == $destination
  then
  	mkdir -p  "/home/app"
 fi
 
 if test ! -d "./$path_to_extracted"
   then 
   	echo "creating destination $destination"
   		mkdir -p $destination
 	fi
# echo "./$path_to_extracted" $destination
# ls -la .
# ls -la $destination
 mv "./$path_to_extracted" $destination
