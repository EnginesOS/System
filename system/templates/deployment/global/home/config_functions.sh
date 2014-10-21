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
touch /home/env_variables
env_variables=`cat /home/system_env_variables /home/env_variables | grep -v "#"`
echo "processing template $file"

while read line
    do
                for env_variable in $env_variables
                  do
                        search_arg=_ENGINES_${env_variable}
                          if   grep -q '*'<<<$line 
                                then
                                        line=${line/$search_arg/\$${env_variable}}
                                        echo $line >> $dest_file
                                        echo $line
                                else
                                        echo " $line"  >> $dest_file
                                        echo "Has * $line"
                                fi
                done

done < $file

}