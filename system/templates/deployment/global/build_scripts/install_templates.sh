#!/bin/bash

cd /home
#	source /home/config_functions.sh
#	copy_substituted_templates
					
if test -d /home/engines/htaccess_files/
 then
htaccess_files=`find /home/engines/htaccess_files/ -type f |grep -v keep_me`
        for file in $htaccess_files
        	do     
                dest_file=`echo $file | sed "/^.*htaccess_files\//s///"`
                dest_dir=`dirname $dest_file`
                
                mkdir -p $dest_dir
                if test -h $dest_file
                then
                	dest_file=`ls -l $dest_file |cut -f2 -d">"`
                fi
            
                 cp $file $dest_file
        done
fi
   