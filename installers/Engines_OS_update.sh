#!/bin/bash

LOGFILE=/tmp/updater.log
. /opt/engos/installers/routines.sh


if test ! -f /tmp/updater.updated
then
	cd /opt/engos
	echo "Downloading changes"
	git pull >>$LOGFILE 
	touch /tmp/updater.updated
	echo "Applying changes"
	$0
	rm /tmp/updater.updated
	exit
fi


#Need to rebuild evrything is generate_keys is run
if test $1 = "-k"
then 
	generate_keys
fi

set_os_flavor

setup_mgmt_git
 


 
remove_services
create_services
set_permissions
echo "Building Images"
 /opt/engos/bin/buildimages.sh >>$LOGFILE 
 
#Fix me need to do a full regen here for all engines or atleast trigger notifcation it needs to be done.
docker stop mgmt
docker rm mgmt

echo "Building System Gui"
/opt/engos/bin/mgmt_startup.sh  >>$LOGFILE 
sleep 180
hostname=`hostname`
echo "Congratulations Engines OS is now upto date please go to http://${hostname}:88/"


 