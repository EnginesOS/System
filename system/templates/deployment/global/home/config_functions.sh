#!/bin/bash


function copy_substituted_templates {

export dbname dbport dbuser dbpass dbhost FRAMEWORK cont_user cont_grp FSCONTFSVolHome SAR TZ
echo  $dbname $dbport $dbuser $dbpass $dbhost $FRAMEWORK $cont_user $cont_grp $FSCONTFSVolHome $SAR $TZ

templates=`find /home/engines/templates/ -type f`
        for file in $templates
        	do     
                dest_file=app/`echo $file | sed "/^.*templates\//s///"`
                dest_dir=`basename $dest_file`
                
                mkdir -p $dest_dir
				rm app/$dest_file
				
                 while read line
                    do
                         eval echo "$line" >> $dest_file
                    done <  $file
        done
}

