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
  	git clone $source_url --depth 1 "./$path_to_extracted"
  elif  test -z "$extraction_command" 
  	 then
  	  wget -O $package_name $source_url
  	  path_to_extracted=$package_name 
  else
	wget -O $package_name $source_url
	if test -z "$path_to_extracted" -o "$path_to_extracted" = './' -o "$path_to_extracted" = '/'
	  then
			path_to_extracted=$destination
			mkdir -p /tmp/$destination
			cd /tmp/$destination			
			$extraction_command /tmp/$package_name
			path_to_extracted=$destination
			cd /tmp
	  else
			$extraction_command $package_name
	fi	
  fi
  
 destination=`echo $destination | sed "/\/$/s///"`
 if ! test "/home/app" == $destination  -o "app" == $destination  -o "/app" == $destination
  then
  	mkdir -p  "/home/app"
 fi
 
 #for single file
 if test ! -d "./$path_to_extracted"
   then 
   	echo "creating destination $destination"
   		mkdir -p $destination
 	fi

if test -d  $destination
 then
    echo "cp -rp ./$path_to_extracted/. $destination"
    if test -f  ./$path_to_extracted 
     then
     	cp -rp "./$path_to_extracted" $destination
     else
 		cp -rp "./$path_to_extracted/." $destination
 	 fi
 else
 	mv "./$path_to_extracted" $destination
fi
if test -f /tmp/$path_to_extracted
 then
	rm /tmp/$path_to_extracted
fi
if test -f tmp/$package_name
 then
rm /tmp/$package_name
fi