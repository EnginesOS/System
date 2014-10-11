#!/bin/bash


function copy_substituted_templates {

templates=`find /tmp/home/engines/configs/ -type f`
        for file in $templates
        	do     
                dest_file=`echo $file | sed "/^.*configs\//s///"`
                dest_dir=`echo $dest_file | sed "/\/[a-Z,0-9,_,.]*$/s///"`
                mkdir -p $dest_dir

                 while read line
                    do
                         eval echo "$line" >> $dest_file
                    done <  $file
        done
}

