#!/bin/bash

if ! test -f ~/.complete_update
 then
   exit
  fi
  
update_ids=`cat ~/.complete_update`

for update_id in $update_ids
 do

export update_id

if ! test -d  /opt/engines/system/updates/engines/$update_id
 then
   exit
  fi
 
 if test -f /opt/engines/system/updates/engines/$update_id/services
  then
  	services=`cat /opt/engines/system/updates/engines/$update_id/services`
  		for service in $services
  		 do
  		 	eservice stop $service >>//opt/engines/system/updates/engines/$update_id/update_log
  		 	eservice recreate $service  >> /opt/engines/system/updates/engines/$update_id/update_log
  		 done
  fi
  

  if test -f /opt/engines/system/updates/engines/$update_id/updater.sh
   then
 		/opt/engines/system/updates/engines/$update_id/updater.sh >> /opt/engines/system/updates/engines/$update_id/update_log
 fi
 

 echo Update $update_id complete
  done
  
  if test $? -eq 0
   then
  	rm ~/.complete_update
  	exit
  fi
  
  echo Problem with $update_id