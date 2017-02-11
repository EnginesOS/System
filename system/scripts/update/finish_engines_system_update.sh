#!/bin/bash

system_updates_dir=/opt/engines/system/updates/to_run/engines
/opt/engines/bin/engines  containers  check_and_act

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
  		 	/opt/engines/bin/engines service $service stop >> $system_updates_dir/$update_id/update_log
  		 #	if  test `/opt/engines/bin/engines service  $service state  |grep running` == stopped 
  		 #	 then  		 	 
  		 		image=`grep image /opt/engines/run/services/$service/running.yaml | cut -f2 -d" "`
  				docker pull $image
  		 		/opt/engines/bin/engines service $service recreate  >>  $system_updates_dir/$update_id/update_log
  		 #	fi
  		 done
  fi
  
 if test -f  $system_updates_dir/$update_id/system_services
  then
  	services=`cat  $system_updates_dir/$update_id/system_services`
  		for service in $services
  		 do
  		  	docker pull engines/$service:` cat /opt/engines/release`  >> $system_updates_dir/$update_id/update_log
 			docker stop $service >> $system_updates_dir/$update_id/update_log
 			/opt/engines/bin/system_service.rb $service destroy >> $system_updates_dir/$update_id/update_log
 			/opt/engines/bin/system_service.rb $service create >> $system_updates_dir/$update_id/update_log
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
 if test -d $system_updates_dir/$update_id 
  then
  	if ! test -d /opt/engines/system/updates/has_run/engines/$update_id 
  	 then
  		mv  $system_updates_dir/$update_id /opt/engines/system/updates/has_run/engines
  	else
  		ts=`date +%d-%m-%Y-%H:%M`
  		cp -rp $system_updates_dir/$update_id /opt/engines/system/updates/has_run/engines/$update_id.$ts
  		rm -r $system_updates_dir/$update_id
  	fi
 fi

  done
  
 
  
  