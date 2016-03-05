#!/bin/bash

echo "Restarting"
sleep 5
#docker stop mgmt >> /var/log/engines/updates/engines_system_update_$ts.log 

cd /opt/engines/etc/services
git pull >/dev/null

cd /opt/engines
git pull


 cp /opt/engines/system/updates/src/etc/sudoers.d/engines /etc/sudoers.d/engines 
 chmod og-rw /etc/sudoers.d/engines 
 
#update_scripts=`ls /opt/engines/system/updates/to_run |grep -v keep`
#if ! test -z  "$update_scripts"
# then
#	echo " $update_scripts" >> ~engines/.complete_update
#fi




#FIX ME and use a list for freash keys only
. /opt/engines/system/updates/routines/script_keys.sh
#refresh_mgmt_keys

/opt/engines/bin/finish_system_update.sh

engines_updates=`ls /opt/engines/system/updates/to_run/engines |grep -v keep`
if ! test -z "$engines_updates"
 then
 	for engine_update in $engines_updates
 	 do
 	 	chown engines /opt/engines/system/updates/to_run/engines/$engine_update
 	    echo chown engines /opt/engines/system/updates/to_run/engines/$engine_update 
	done
 fi
 su -l engines /opt/engines/bin/finish_update.sh


exit 0