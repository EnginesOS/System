#!/bin/bash
touch /opt/engines/run/system/flags/update_engines_running 
chown engines /opt/engines/run/system/flags/update_engines_running 

cd /opt/engines/etc/serivces
git pull

cd /opt/engines
git pull

 cp /opt/engines/system/updates/src/etc/sudoers.d/engines /etc/sudoers.d/engines 
 chmod og-rw /etc/sudoers.d/engines 
 
update_scripts=`ls /opt/engines/system/updates/to_run |grep -v keep`
if ! test -z  $update_scripts
 then
	echo " $update_scripts" >> ~engines/.complete_update
fi

chown engines ~engines/.complete_update


#FIX ME and use a list for freash keys only
. /opt/engines/system/updates/routines/script_keys.sh
#refresh_mgmt_keys

/opt/engines/bin/finish_system_update.sh

chown engines `ls /opt/engines/system/updates/to_run/engines`

sudo su -l engines /opt/engines/bin/finish_update.sh


exit $?