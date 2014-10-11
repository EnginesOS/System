#!/bin/bash


function copy_substituted_templates {

export dbname dbport dbuser dbpass dbhost FRAMEWORK cont_user cont_grp FSCONTFSVolHome SAR TZ
echo  $dbname $dbport $dbuser $dbpass $dbhost $FRAMEWORK $cont_user $cont_grp $FSCONTFSVolHome $SAR $TZ

templates=`find /tmp/home/engines/templates/ -type f`
        for file in $templates
        	do     
                dest_file=`echo $file | sed "/^.*templates\//s///"`
                dest_dir=app/`echo $dest_file | sed "/\/[a-z,A-Z,0-9,_,.]*$/s///"`
                
                mkdir -p $dest_dir

                 while read line
                    do
                         eval echo "$line" >> $dest_file
                    done <  $file
        done
}

