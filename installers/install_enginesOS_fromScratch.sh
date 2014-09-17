 #!/bin/bash



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
		  cat /etc/rc.local | sed "/exit.*/s/su -l dockuser \/opt\/engos\/bin\/mgmt_startup.sh/" >> /tmp/rc.local
		 echo "exit 0"  >> /tmp/rc.local
		 cp /tmp/rc.local /etc/rc.local
		 rm  /tmp/rc.local
		 chmod u+x  /etc/rc.local
		 
		
		
		 apt-get install apt-transport-https
		 echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
		 apt-get -y update
		 apt-get -y  --force-yes install lxc-docker
		 
		 echo "DOCKER_OPTS=\"--dns  172.17.42.1 --dns 8.8.8.8\" " >> /etc/default/docker 
		 
		 #kludge to deal with the fact we install bind just to get dnssec-keygen
		 bind=`service bind9 status  |grep unrecognized | wc -l`
		 
		 apt-get -y install imagemagick cmake bind9 dc mysql-client libmysqlclient-dev unzip wget git
		 
		 #Only Remove if not present
		 if test $bind -eq 0
		 	then
		 		update-rc.d bind9 remove
		 	fi
		 
		 #Kludge should not be a static but a specified or atleaqst checked id
		 adduser -q --uid 21000 --ingroup docker  -gecos "Engines OS User"  --home /home/dockuser --disabled-password dockuser
		 
		echo "PATH=\"/opt/engos/bin:$PATH\"" >>~dockuser/.profile 
		
		\curl -L https://get.rvm.io | bash -s stable 
		echo ". /etc/profile.d/rvm.sh" >> ~dockuser/.login 
		
		
		/usr/local/rvm/bin/rvm install ruby-2.1.1
		 rvm use ruby-2.1.1 
		
gem install git

  }

function generate_keys {
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
	cat /opt/engos/system/images/03.serviceImages/dns/named.conf.default-zones.ad.tmpl | sed "/KEY_VALUE/s//$key/" > /opt/engos/system/images/03.serviceImages/dns/named.conf.default-zones.ad
	cp ddns.* /opt/engos/system/images/01.baseImages/01.base/
	mv ddns.* /opt/engos/etc/keys/
}

function set_permissions {
	chown -R dockuser /opt/engos/ /var/lib/engos ~dockuser/
	
	}

function set_os_flavor {
	if test $1 = "ubuntu"
	then
		files=`find system/images/ -name "*.ubuntu"`
			for file in $files
				do
					new_name=`echo $file | sed "/.ubuntu/s///"`
					cp $file $new_name
				done
	fi
}

function create_services {
	su -l dockuser /opt/engos/bin/engines.rb service create dns
	sleep 30
	su -l dockuser /opt/engos/bin/engines.rb service create mysql_server
	su -l dockuser /opt/engos/bin/engines.rb service create nginx
	su -l dockuser /opt/engos/bin/engines.rb service create monit
	su -l dockuser /opt/engos/bin/engines.rb service create cAdvisor
}

function setup_mgmt_git {
rm 
	cd /opt/engos/system/images/04.systemApps/mgmt/home/app
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
	git pull
}

install_docker_and_components
configure_git 
generate_keys
set_os_flavor
set_permissions

setup_mgmt_git


mkdir -p /var/lib/engos

su -l dockuser /opt/engos/bin/buildimages.sh





su -l dockuser /opt/engos/bin/mgmt_startup.sh 


 