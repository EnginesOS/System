#!/bin/sh


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

 
   
echo Source URL $source_url 
echo Extract with $extraction_command from  $package_name to $path_to_extracted 
echo Install to $destination


 if test "$extraction_command" = 'git'
  then
    if ! test -z $git_username
      then
       url=`echo $source_url |sed "/https:../s///"`
       source_url=https://${git_username}:${git_password}@$url
   fi    
  	git  clone $download_options --depth 1  $source_url "./$path_to_extracted"
  elif  test -z "$extraction_command" 
  	 then
  	  wget -O $package_name $source_url
  	  path_to_extracted=$package_name 
  else
	wget -O $package_name $source_url
	  if test -z "$path_to_extracted" -o "$path_to_extracted" = './' -o "$path_to_extracted" = '/'
		then
			path_to_extracted=app
			mkdir /tmp/app
			cd /tmp/app			
			$extraction_command ../$package_name
			cd /tmp
		else
			$extraction_command $package_name
	  fi	
  fi
 
