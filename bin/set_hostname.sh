#/bin/bash

hostname=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $2}'`
domain_name=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $3}'`

#hostname=$1
#$domain_name=$2

if ! test -z "$domain_name"
 then
  hostname=${hostname}.$domain_name
  fi
  
  echo sudo hostname $hostname
   sudo hostname $hostname
