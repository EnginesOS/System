#/bin/bash



sudo /opt/engines/scripts/_system_update.sh

cd /opt/engines

prior_release=`cat /opt/engines/release`

cp  /opt/engines/release /opt/engines/release.last
git pull

if test -f /opt/engines/installers/update_${prior_release}.sh
	then
		update_${prior_release}.sh
	fi
	
update_system_images.sh



