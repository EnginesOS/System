#!/bin/bash
/opt/engines/bin/set_ip.sh


/opt/engines/bin/eservices check_and_act all

/opt/engines/bin/engines check_and_act all

if test -f  /opt/engines/.complete_install
then
   /opt/engines/installers/finish_install.sh
fi 

