#!/bin/bash

system_updates_dir=/opt/engines/system/updates/to_run/engines


update_ids=`ls /opt/engines/system/updates/to_run/engines |grep -v keep`

for update_id in $update_ids
 do

export update_id

if ! test -d  $system_updates_dir/$update_id
 then
   exit
  fi
 
 
 if test -f  $system_updates_dir/$update_id/services
  then
  	services=`cat  $system_updates_dir/$update_id/services`
  		for service in $services
  		 do
  		 	eservice stop $service >> $system_updates_dir/$update_id/update_log
  		 	eservice recreate $service  >>  $system_updates_dir/$update_id/update_log
  		 done
  fi
  

  if test -f  $system_updates_dir/$update_id/updater.sh
   then
 		 $system_updates_dir/$update_id/updater.sh >>  $system_updates_dir/$update_id/update_log
 		if test $? -ne 0
 		 then
 		 echo Problem with $update_id
 		 cat  $system_updates_dir/$update_id/update_log
 		 mv  $system_updates_dir/$update_id /opt/engines/system/updates/failed/engines
 		 exit
 		  
 		 fi
 fi
 it test -d $system_updates_dir/$update_id 
  then
  	mv  $system_updates_dir/$update_id /opt/engines/system/updates/has_run/engines
 fi

  done
  
 
  	rm ~/.complete_update
  