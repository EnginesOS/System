#!/bin/bash
ts=`date +%d%m%Y_%H:%M:%S`
release=`cat /opt/engines/release`

. /opt/engines/system/updates/routines/script_keys.sh

refresh_mgmt_keys

#as a matter of course
docker pull engines/volbuilder:$release

if test -f /opt/engines/system/updates/services_to_update
 then
    for service in `cat /opt/engines/system/updates/services_to_update`
   		do
   			eservice status $service |grep running
   			if test $? -eq 0
   			 then
   			    eservice stop $service 
   			 	eservice recreate $service
   			 fi
   		done 
   		
 mv /opt/engines/system/updates/services/to_update /opt/engines/system/updates/services/updated/services_updated.$ts
 
 
 fi

for script in `ls /opt/engines/system/updates/to_run/ |grep -v keep_me `
 do
  /opt/engines/system/updates/to_run/$script
  mv /opt/engines/system/updates/to_run/$script /opt/engines/system/updates/have_run/$script.$ts
 done