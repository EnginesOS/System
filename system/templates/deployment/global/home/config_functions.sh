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
                 
               #write=`stat -c  %A $dest_file | awk -F\-  '{ print $3}' |grep w |wc -c`
               #echo $write
               #if test $write -eq 0
                #then
                   #_dest_file=`echo $dest_file | sed "/home/s///"`
                   #echo "echo $dest_file | sed "/home/s///""
                   
                  #/home/engines/scripts/grant_rw_access.sh `dirname $_dest_file`
                 # /home/engines/scripts/grant_rw_access.sh $_dest_file
                #fi
               
                 cp $file $dest_file
				#rm $dest_file
				
				#echo doing $dest_file
				
#      			process_file 
#       			#FIXME only revoke if it was g+w before
#       			if test $write -eq 0
#       			then
#       				 $_dest_file=`echo $dest_file | sed  "/home/s///"`
#       				/home/engines/scripts/revoke_rw_access.sh $_dest_file
#       				/home/engines/scripts/revoke_rw_access.sh `dirname $_dest_file`
#				fi
        done
fi
        echo run as `whoami` in `pwd`
}

#function process_file {
#cat /home/app.env |cut -f1 -d= >/home/app/app_env_variables
#env_variables=`cat /home/system_env_variables /home/app/app_env_variables | grep -v "#"`
#env_variables=`set | awk '{print $1}'`
#env_variables=`cat /home/app.env`
#echo "processing template $file"
#raw=0
#while read line
#    do
#                for env_variable in $env_variables
#                  do
#                        search_arg=_ENGINES_${env_variable}
#                         if   grep -q '*'<<<$line
#                                then
#                                #or if $ replace with _STAR_ and _Dollar_ and then replace back at end
#                                        raw=1
#                                elif  grep -q $search_arg <<<$line
#                               then
#                                        eval replacement_str='$'${env_variable}                                        
#                                        line=${line/$search_arg/${replacement_str}}
#                                        echo " PROCESSING MATCH ON ${env_variable} which matched  $search_arg"
#                                        echo " to give $line = search $search_arg replace with ${replacement_str} "                                         
#                                        raw=0
#                                else
#                                		raw=1
#                                fi
 #               done
#
#         if test $raw -eq 0
#         then
#                echo $line >> $dest_file
#         else
#                echo "$line">> $dest_file
#         fi                                                  
# 
#done < $file
#
#}