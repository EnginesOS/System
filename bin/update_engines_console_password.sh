#!/bin/bash

args=$SSH_ORIGINAL_COMMAND

config_params=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $2}'`

n=1

fcnt=`echo $config_params| grep -o : |wc -l`

fcnt=`expr $fcnt + 1`

        while test $fcnt -ge $n
        do
                nvp="`echo $config_params |cut -f$n -d:`"
                n=`expr $n + 1`
                name=`echo $nvp |cut -f1 -d=`
                value=`echo $nvp |cut -f2 -d=`
                if test ${#name} -gt 0
                	then
                		export $name="$value"
                	fi
        done
        
if test -z $console_password
 then
 	echo Error:no Console Password
 	exit -1
 fi
 
 sudo /opt/engines/bin/scripts/_update_engines_console_password.sh $console_password
 