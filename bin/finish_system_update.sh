#!/bin/bash

system_updates_dir=/opt/engines/system/updates/to_run/system


update_ids=`ls /opt/engines/system/updates/to_run/system`


for update_id in $update_ids
 do

export update_id

if ! test -d  $system_updates_dir/$update_id
 then
   exit
  fi

   if test -f $system_updates_dir/$update_id/updater.sh
   then
 		$system_updates_dir/$update_id/updater.sh >> $system_updates_dir/$update_id/update_log
 		if test $? -eq 0
   then
  	echo Problem with $update_id
  	cat $system_updates_dir/$update_id/update_log
  		mv  $system_updates_dir/$update_id /opt/engines/system/updates/failed/system
   else    
  
  	echo Success sytem update $update_id
  fi
 fi
 	mv  $system_updates_dir/$update_id /opt/engines/system/updates/has_run/system
    echo "mv  $system_updates_dir/$update_id /opt/engines/system/updates/has_run/system"
  done
  
  
  