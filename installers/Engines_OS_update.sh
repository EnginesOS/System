#!/bin/bash

LOGFILE=/tmp/updater.log

function create_services {
echo "Creating and starting Engines OS Services"

	 /opt/engos/bin/engines.rb service create dns >>$LOGFILE 
	sleep 30
	 /opt/engos/bin/engines.rb service create mysql_server >>$LOGFILE
	 /opt/engos/bin/engines.rb service create nginx >>$LOGFILE
	 /opt/engos/bin/engines.rb service create monit >>$LOGFILE
	 /opt/engos/bin/engines.rb service create cAdvisor >>$LOGFILE
}

function remove_services {
echo "Creating and starting Engines OS Services"

	 /opt/engos/bin/engines.rb service stop dns >>$LOGFILE
	 /opt/engos/bin/engines.rb service stop mysql_server >>$LOGFILE
	 /opt/engos/bin/engines.rb service stop nginx >>$LOGFILE
	 /opt/engos/bin/engines.rb service stop monit >>$LOGFILE
	 /opt/engos/bin/engines.rb service stop cAdvisor >>$LOGFILE
	  docker rm dns >>$LOGFILE
	 docker rm mysql_server >>$LOGFILE
	 docker  rm nginx >>$LOGFILE
	 docker rm monit >>$LOGFILE
	 docker  rm cAdvisor  >>$LOGFILE
}

function generate_keys {
echo "Generating system Keys"
	/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 128 -n HOST  -r /dev/urandom -n HOST DDNS_UPDATE >>$LOGFILE
	mv *private ddns.private 
	mv *key ddns.key 
	mv ddns.* /opt/engos/etc/keys/ 
	
	ssh-keygen -q -N "" -f nagios >>$LOGFILE 
	ssh-keygen -q -N "" -f mysql  >>$LOGFILE 
	ssh-keygen -q -N "" -f mgmt >>$LOGFILE
	ssh-keygen -q -N "" -f nginx >>$LOGFILE
	
	mv  mgmt nagios mysql nginx /opt/engos/etc/keys/ 
	cp  mgmt.pub  nagios.pub  mysql.pub  nginx.pub  /opt/engos/etc/keys/ 
		
	cp /opt/engos/etc/keys/mysql.pub /opt/engos/system/images/03.serviceImages/mysql/ 
	cp /opt/engos/etc/keys/nagios.pub /opt/engos/system/images/04.systemApps/nagios/ 
	cp /opt/engos/etc/keys/nginx.pub /opt/engos/system/images/04.systemApps/nginx/  
	cp /opt/engos/etc/keys/mgmt.pub  /opt/engos/system/images/03.serviceImages/mgmt/ 
	
	key=`cat /opt/engos/etc/keys/ddns.private |grep Key | cut -f2 -d" "` >>$LOGFILE
	cat /opt/engos/system/images/03.serviceImages/dns/named.conf.default-zones.ad.tmpl | sed "/KEY_VALUE/s//"$key"/" > /opt/engos/system/images/03.serviceImages/dns/named.conf.default-zones.ad  
	cp /opt/engos/etc/keys/ddns.* /opt/engos/system/images/01.baseImages/01.base/ 

}

function set_os_flavor {
echo "Configuring OS Specific Dockerfiles"
	if test `uname -v |grep Ubuntu |wc -c` -gt 0
	then
		files=`find /opt/engos/system/images/ -name "*.ubuntu"`
			for file in $files
				do
					new_name=`echo $file | sed "/.ubuntu/s///"`
					rm $new_name
					mv $file $new_name
				done
	elif test `uname -v |grep Debian  |wc -c` -gt 0
	then
		for file in $files
				do
					new_name=`echo $file | sed "/.debian/s///"`
					rm $new_name
					mv $file $new_name
				done
		else
			echo "Unsupported Linux Flavor "
			uname -v
			exit	
	fi
}

function setup_mgmt_git {
echo "Seeding Mgmt Application source from repository"
	 cd /opt/engos/system/images/04.systemApps/mgmt/home/app
	  if test ! -f .git/config
		then
			git init
			echo '[core]
				        repositoryformatversion = 0
				        filemode = true
				        bare = false
				        logallrefupdates = true
				[branch "master"]
				[remote "origin"]
				        url = https://github.com/EnginesOS/SystemGui.git
				        fetch = +refs/heads/*:refs/remotes/origin/*
				[branch "master"]
				        remote = origin
				        merge = refs/heads/master
				' > .git/config		
		fi
		git pull >>$LOGFILE 
}


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
#generate_keys

set_os_flavor

setup_mgmt_git
 


echo "Building Images"
 /opt/engos/bin/buildimages.sh >>$LOGFILE 
 
remove_services
create_services

#Fix me need to do a full regen here for all engines or atleast trigger notifcation it needs to be done.
docker stop mgmt
docker rm mgmt

echo "Building System Gui"
/opt/engos/bin/mgmt_startup.sh  >>$LOGFILE 
sleep 180
hostname=`hostname`
echo "Congratulations Engines OS is now upto date please go to http://${hostname}:88/"


 