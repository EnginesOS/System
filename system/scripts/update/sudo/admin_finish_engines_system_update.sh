#!/bin/bash
#not a sudo script as such but call from a sudo script

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
 		$system_updates_dir/$update_id/updater.sh &>> $system_updates_dir/$update_id/update_log
 		if test $? -eq 0
   then
  	echo Problem with $update_id
  	cat $system_updates_dir/$update_id/update_log
  		mv  $system_updates_dir/$update_id /opt/engines/system/updates/failed/system
   else    
  
  	echo Success sytem update $update_id
  fi
 fi
 if ! test -d /opt/engines/system/updates/has_run/system/$update_id 
  	 then
  		mv  $system_updates_dir/$update_id /opt/engines/system/updates/has_run/system
  	else
  		ts=`date +%d-%m-%Y-%H:%M`
  		cp -rp $system_updates_dir/$update_id /opt/engines/system/updates/has_run/system/$update_id.$ts
  		rm -r $system_updates_dir/$update_id
  	fi
 	
  done
  
  
  