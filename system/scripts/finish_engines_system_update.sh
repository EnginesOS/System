#!/bin/sh

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
echo Applying update $update_id &>> $system_updates_dir/$update_id/update_log 		 
 
 if test -f  $system_updates_dir/$update_id/services
  then
  	services=`cat  $system_updates_dir/$update_id/services`
  	echo $services |grep ALL >/dev/null
  	if test $? -eq 0
  	 then
  	 services=` engines services container_name |tr '"[],' ' '`
  	 
  	  # services=`ls /opt/engines/run/services`
  	 fi 
  	 
  		for service in $services
  		 do  		 
  		 if test -f /opt/engines/run/services/$service/running.yaml
  		  then
  		    if  ! test `/opt/engines/bin/engines service $service state` = nocontainer
  		     then  		      
  		 	/opt/engines/bin/engines service $service stop &>> $system_updates_dir/$update_id/update_log 		 	 
  		 	image=`grep image /opt/engines/run/services/$service/running.yaml | cut -f2 -d" "`
  			docker pull $image
  			
  			/opt/engines/bin/engines service $service wait_for stop 60
  			rm /opt/engines/run/services/$service/running.yaml*
  		 	/opt/engines/bin/engines service $service recreate &>>  $system_updates_dir/$update_id/update_log
  		 	/opt/engines/bin/engines service $service wait_for start 30
			/opt/engines/bin/engines service $service wait_for_startup 60
			fi			
		  fi
  		 done
  		 docker rmi `docker images |grep none |awk '{print $3}'`
  fi
  
 if test -f  $system_updates_dir/$update_id/system_services
  then
  	services=`cat  $system_updates_dir/$update_id/system_services`
  		for service in $services
  		 do
  		    echo "Recreate Service $service" &>> $system_updates_dir/$update_id/update_log
  		    
  		  	docker pull engines/$service:` cat /opt/engines/release`  &>> $system_updates_dir/$update_id/update_log
 			
 			#sleep 30
 			/opt/engines/bin/system_service.rb $service stop &>> $system_updates_dir/$update_id/update_log
 			/opt/engines/bin/system_service.rb $service wait_for stop 60
 			/opt/engines/bin/system_service.rb $service destroy &>> $system_updates_dir/$update_id/update_log
 			/opt/engines/bin/system_service.rb $service wait_for destroy 20
 			rm /opt/engines/run/system_services/$service/running.yaml*
 			/opt/engines/bin/system_service.rb $service create &>> $system_updates_dir/$update_id/update_log
 			/opt/engines/bin/system_service.rb $service wait_for create 30
 			/opt/engines/bin/system_service.rb $service start
 			/opt/engines/bin/system_service.rb $service wait_for start 30
 			/opt/engines/bin/system_service.rb $service wait_for_startup 60
  		 done
  		 docker rmi `docker images |grep none |awk '{print $3}'`
  fi
  
  if test -f  $system_updates_dir/$update_id/updater.sh
   then
 		 $system_updates_dir/$update_id/updater.sh &>>  $system_updates_dir/$update_id/update_log
 		if test $? -ne 0
 		 then
 		 echo Problem with $update_id
 		 cat  $system_updates_dir/$update_id/update_log
 		 cp -rp  $system_updates_dir/$update_id /opt/engines/system/updates/failed/engines
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
  
 
  
  