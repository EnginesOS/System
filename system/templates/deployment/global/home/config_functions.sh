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
				
      #           while read line
      #              do                         
      #              #/eng_value/s//$value/
      #                   eval echo "$line" >> $dest_file
       #             done <  $file
       			process_file 
        done
}

function process_file {
touch /home/app/env_variables
env_variables=`cat /opt/engsos/etc/env_variables /home/app/env_variables | grep -v #`

while read line
    do
                for env_variable in $env_variables
                  do
                        search_arg=_ENGINES_${env_variable}
                          if test  `echo  "$line"       | grep '*' |wc -c ` -eq 0
                                then
                                        line=${line/$search_arg/\$${env_variable}}
                                        echo $line >> $dest_file
                                        echo $line
                                else
                                        echo " $line"  >> $dest_file
                                fi
                done

done < $file

}