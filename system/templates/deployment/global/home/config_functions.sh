#!/bin/bash


function copy_substituted_templates {

#run with /home/app

export dbname dbport dbuser dbpass dbhost FRAMEWORK cont_user cont_grp FSCONTFSVolHome SAR TZ
echo  $dbname $dbport $dbuser $dbpass $dbhost $FRAMEWORK $cont_user $cont_grp $FSCONTFSVolHome $SAR $TZ

templates=`find /home/engines/templates/ -type f |grep -v keep_me`
        for file in $templates
        	do     
                dest_file=`echo $file | sed "/^.*templates\//s///"`
                dest_dir=`dirname $dest_file`
                
                mkdir -p $dest_dir
				rm $dest_file
				
				echo doing $dest_file
				
       			process_file 
        done
}

function process_file {

env_variables=`cat /home/system_env_variables  | grep -v "#"`
echo "processing template $file"
raw=0
while read line
    do
                for env_variable in $env_variables
                  do
                        search_arg=_ENGINES_${env_variable}
                         if   grep -q '*'<<<$line
                                then
                                        raw=1
                                else
                                        eval replacement_str='$'${env_variable}
                                        line=${line/$search_arg/${replacement_str}} 
                                        raw=0
                                fi
                done

         if test $raw -eq 0
         then
                echo $line
         else
                echo "$line"
         fi                                                  
 
done < $file

}