#!/bin/bash
if test -z $overwrite_existing
 then
  overwrite_existing=true
 fi
 if test $overwrite_existing == true
  then
    rm /home/app/.ssh/single_access /home/app/.ssh/single_access.pub /home/app/.ssh/authorized_keys
  fi
  
  if ! test -f  /home/app/.ssh/authorized_keys
   then
    ssh-keygen -q -N "" -f /home/app/.ssh/single_access
    cp /home/app/.ssh/single_access.pub  /home/app/.ssh/authorized_keys
   fi
cat /home/app/.ssh/single_access