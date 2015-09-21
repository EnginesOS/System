#!/bin/bash
/opt/engines/bin/set_ip.sh

echo Clearing Flags

rm -f /opt/engines/run/system/flags/reboot_required 
rm -f /opt/engines/run/system/flags/engines_rebooting 
rm -f /opt/engines/run/system/flags/building_params 
#rm -f /opt/engines/run/system/flags/

/opt/engines/bin/eservices check_and_act 

/opt/engines/bin/engines check_and_act 

if test -f  ~/.complete_install
then
   /opt/engines/installers/finish_install.sh
fi 

