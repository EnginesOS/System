#!/bin/bash
touch /opt/engines/run/system/flags/update_engines_running 
chown engines /opt/engines/run/system/flags/update_engines_running 
cd /opt/engines
git pull
 cp /opt/engines/system/updates/src/etc/sudoers.d/engines /etc/sudoers.d/engines 
 chmod og-rw /etc/sudoers.d/engines 
 
update_scripts=`ls /opt/engines/system/updates/to_run`
for script in $update_scripts
 do
 	if ! test -f /opt/engines/system/updates/have_run/$script
 		then
 		/opt/engines/system/updates/to_run/$script
 		echo ran /opt/engines/system/updates/to_run/$script
 		cp /opt/engines/system/updates/to_run/$script /opt/engines/system/updates/have_run/$script
 	fi
 done
 
exit $?