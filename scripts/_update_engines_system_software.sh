#!/bin/bash

echo "Updating files"


echo "update service defs"
cd /opt/engines/etc/services
git pull >/dev/null

echo "update System"
cd /opt/engines
git pull


 cp /opt/engines/system/updates/src/etc/sudoers.d/engines /etc/sudoers.d/engines 
 chmod og-rw /etc/sudoers.d/engines 



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