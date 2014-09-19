 #!/bin/bash
RUBY_VER=2.1.2


function configure_git {
	
	mkdir -p /opt/engos/
	cd /opt/engos/
	git init 
	
	echo '[core]
	        repositoryformatversion = 0
	        filemode = true
	        bare = false
	        logallrefupdates = true
	[branch "master"]
	[remote "origin"]
	        url = https://github.com/EnginesOS/System
	        fetch = +refs/heads/*:refs/remotes/origin/*
	[branch "master"]
	        remote = origin
	        merge = refs/heads/master
	' > .git/config
	git pull
}
  
  function install_docker_and_components {
  
  echo "updating OS to Latest"
  
  apt-get -y  --force-yes update
  
  #Not something we should do as can ask grub questions and will confuse no techy on aws
  #apt-get -y  --force-yes upgrade
  
  echo "Adding startup script"
		 cat /etc/rc.local | sed "/exit.*/s/su -l dockuser \/opt\/engos\/bin\/mgmt_startup.sh//" > /tmp/rc.local
		 echo "exit 0"  >> /tmp/rc.local
		 cp /tmp/rc.local /etc/rc.local
		 rm  /tmp/rc.local
		 chmod u+x  /etc/rc.local
		 
		
echo "Installing Docker"		
		 apt-get install apt-transport-https
		 echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
		 apt-get -y update
		 apt-get -y  --force-yes install lxc-docker
	
echo "Configuring Docker DNS settings"	 
		 echo "DOCKER_OPTS=\"--dns  172.17.42.1 --dns 8.8.8.8\" " >> /etc/default/docker 
		 
		 #need to restart to get dns set
		 service docker stop
		 sleep 20
		 service docker start
		  
echo "Installing required  packages"
		 #kludge to deal with the fact we install bind just to get dnssec-keygen
		 bind=`service bind9 status  |grep unrecognized | wc -l`
		 
		 apt-get -y install imagemagick cmake bind9 dc mysql-client libmysqlclient-dev unzip wget git
		 
		 #Only Remove if not present
		 if test $bind -eq 0
		 	then
		 	service bind9 stop
		 		update-rc.d bind9 remove
		 	fi
		 
echo "Setting up engines system user"
		 #Kludge should not be a static but a specified or atleaqst checked id
		 adduser -q --uid 21000 --ingroup docker  -gecos "Engines OS User"  --home /home/dockuser --disabled-password dockuser
		 
		echo "PATH=\"/opt/engos/bin:$PATH\"" >>~dockuser/.profile 
		
echo "Installing ruby"
		\curl -L https://get.rvm.io | bash -s stable 
		echo ". /etc/profile.d/rvm.sh" >> ~dockuser/.login 		
		
		/usr/local/rvm/bin/rvm install ruby-$RUBY_VER

		rvm  --default use ruby-$RUBY_VER
		 
		gem install git
 		/usr/local/rvm/bin/rvm gemset create git
 		#Following needed for rspec tests
		gem install multi_json
		/usr/local/rvm/bin/rvm gemset create multi_json
		gem install multi_json rspec
		/usr/local/rvm/bin/rvm gemset create 	rspec
  }

function generate_keys {
echo "Generating system Keys"
	dnssec-keygen -a HMAC-MD5 -b 128 -n HOST  -r /dev/urandom -n HOST DDNS_UPDATE
	mv *private ddns.private
	mv *key ddns.key
	
	ssh-keygen -q -N "" -f nagios
	ssh-keygen -q -N "" -f mysql
	ssh-keygen -q -N "" -f mgmt
	ssh-keygen -q -N "" -f nginx
	
	mv  mgmt nagios mysql nginx /opt/engos/etc/keys/
	mv mysql.pub /opt/engos/system/images/03.serviceImages/mysql/
	mv nagios.pub /opt/engos/system/images/04.systemApps/nagios/
	mv nginx.pub /opt/engos/system/images/04.systemApps/nginx/
	mv mgmt.pub  /opt/engos/system/images/04.systemApps/mgmt/
	
	key=`cat ddns.private |grep Key | cut -f2 -d" "`
	cat /opt/engos/system/images/03.serviceImages/dns/named.conf.default-zones.ad.tmpl | sed "/KEY_VALUE/s//"$key"/" > /opt/engos/system/images/03.serviceImages/dns/named.conf.default-zones.ad
	cp ddns.* /opt/engos/system/images/01.baseImages/01.base/
	mv ddns.* /opt/engos/etc/keys/
}

function set_permissions {
echo "Setting directory and file permissions"
	chown -R dockuser /opt/engos/ /var/lib/engos ~dockuser/ 
	
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

function create_services {
echo "Creating and startingg Engines OS Services"
	su -l dockuser /opt/engos/bin/engines.rb service create dns
	sleep 30
	su -l dockuser /opt/engos/bin/engines.rb service create mysql_server
	su -l dockuser /opt/engos/bin/engines.rb service create nginx
	su -l dockuser /opt/engos/bin/engines.rb service create monit
	su -l dockuser /opt/engos/bin/engines.rb service create cAdvisor
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
		git pull
}

install_docker_and_components
configure_git 
generate_keys
set_os_flavor

setup_mgmt_git

mkdir -p /var/lib/engos/fs

set_permissions

echo "Building Images"
su -l dockuser /opt/engos/bin/buildimages.sh

create_services

echo "System startup"
su -l dockuser /opt/engos/bin/mgmt_startup.sh 
sleep 180  # would be noce to tail docker logs -f mgmt and break when :8000 in log line
hostname=`hostname`
echo "Congratulations Engines OS is now installed please go to http://${hostname}:88/"


 