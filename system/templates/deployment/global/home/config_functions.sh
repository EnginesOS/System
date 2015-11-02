#!/bin/bash

function copy_substituted_templates {

if test -d /home/engines/templates/
 then
templates=`find /home/engines/templates/ -type f |grep -v keep_me`
        for file in $templates
        	do     
                dest_file=`echo $file | sed "/^.*templates\//s///"`
                dest_dir=`dirname $dest_file`
                
                mkdir -p $dest_dir
                if test -h $dest_file
                then
                	dest_file=`ls -l $dest_file |cut -f2 -d">"`
                fi
            
                 cp $file $dest_file
                 if ! test -z  "$USER"
                  then
                 	chown $USER $dest_file
                  fi

        done
fi
        echo run as `whoami` in `pwd`
}

