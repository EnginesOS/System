#!/bin/bash



if ! test -f ~/.complete_system_update
 then
   exit
  fi
  
update_ids=`cat ~/.complete_system_update`

for update_id in $update_ids
 do

export update_id

if ! test -d  /opt/engines/system/updates/engines/$update_id
 then
   exit
  fi

   if test -f /opt/engines/system/updates/system/$update_id/updater.sh
   then
 		/opt/engines/system/updates/system/$update_id/updater.sh >> /opt/engines/system/updates/system/$update_id/update_log
 fi
 




  done
  if test $? -eq 0
   then
  	rm ~/.complete_update
  	exit
  fi
  
  echo Problem with $update_id