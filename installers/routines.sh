#!/bin/bash
RUBY_VER=2.1.3



function configure_git {

	apt-get install -y git
	
	mkdir -p /opt/
	
	
	#engines/
	#cd /opt/engines/
	#git init 
	git clone https://github.com/EnginesOS/System.git --branch alpha  --single-branch /opt/engines/
	#git remote add -t alpha origin 	https://github.com/EnginesOS/System.git
	#git fetch
	
#	echo '[core]
#	        repositoryformatversion = 0
#	        filemode = true
#	        bare = false
#	        logallrefupdates = true
#	[branch "master"]
#	[remote "origin"]
#	        url = https://github.com/EnginesOS/System
#	        fetch = +refs/heads/*:refs/remotes/origin/*
#	[branch "master"]
#	        remote = origin
#	        merge = refs/heads/master
#	' > .git/config
#	git pull


}
  
  function install_docker_and_components {
  
  echo "updating OS to Latest"
  
  apt-get -y  --force-yes update
  
  #Not something we should do as can ask grub questions and will confuse no techy on aws
  #apt-get -y  --force-yes upgrade
  
  echo "Adding startup script"
		 cat /etc/rc.local | sed "/^exit.*$/s//su -l engines \/opt\/engines\/bin\/mgmt_startup.sh/" > /tmp/rc.local
		 echo "exit 0"  >> /tmp/rc.local
		 cp /tmp/rc.local /etc/rc.local
		 rm  /tmp/rc.local
		
		 chmod u+x  /etc/rc.local
		 

	
		 
		 
		
echo "Installing Docker"		
		 apt-get install apt-transport-https
		 echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
		 apt-get -y update
#IF AWS	 and not devmapper	 
		#  apt-get install -y linux-image-extra-$(uname -r) -qq
		 wget -qO- https://get.docker.io/gpg | apt-key add -
		 apt-get -y  --force-yes install lxc-docker
	
echo "Configuring Docker DNS settings"	 
		 echo "DOCKER_OPTS=\"--storage-driver=devicemapper --dns  172.17.42.1 --dns 8.8.8.8  --bip=172.17.42.1/16\"" >> /etc/default/docker 
	
		 #need to restart to get dns set
		 service docker stop
		 sleep 20
		 service docker start
		  
echo "Installing required  packages"
		 #kludge to deal with the fact we install bind just to get dnssec-keygen
		 bind=`service bind9 status  |grep unrecognized | wc -l`
		 
		 #echo "Configure Apt-cache"
		 # apt-get -y install apt-cacher
		  
		  
		#echo "allowed_hosts = *" >>  /etc/apt-cacher/apt-cacher.conf
		
		 apt-get -y install libssl-dev  imagemagick cmake bind9 dc mysql-client libmysqlclient-dev unzip wget git 
		
		 
		 #Only Remove if not present
		 if test $bind -eq 0
		 	then
		 	service bind9 stop
		 		update-rc.d bind9 disable
		 	fi
		 
echo "Setting up engines system user"
		 #Kludge should not be a static but a specified or atleaqst checked id
		 adduser -q --uid 21000 --ingroup docker   -gecos "Engines OS User"  --home /home/engines --disabled-password engines
		 addgroup engines
		 usermod  -G engines engines
		  usermod -u 22015 backup
		  usermod  -a -G engines  backup
		echo "PATH=\"/opt/engines/bin:$PATH\"" >>~engines/.profile 
		
echo "Installing ruby"

#10 gems installed
#cp: cannot stat â: No such file or directory
#cp: cannot stat â: No such file or directory
#cp: cannot stat â: No such file or directory
#cp: cannot stat â: No such file or directory
#Setting directory and file permissions
#chown: cannot access â: No such file or directory
#Enter new UNIX password: 


mkdir -p /usr/local/  
cd /usr/local/  
git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv

	chgrp -R engines rbenv
	chmod -R g+rwxXs rbenv
	
	cd /usr/local/rbenv   

	git clone git://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
	chgrp -R engines plugins/ruby-build
	chmod -R g+rwxs plugins/ruby-build
	
	echo 'export PATH="/usr/local/rbenv/bin:$PATH"' >> ~/.bashrc 
	echo 'eval "$(rbenv init -)"' >> ~/.bashrc ; .  ~/.bashrc
	source ~/.bashrc 
	 
	echo 'export PATH="/usr/local/rbenv/bin:$PATH"' >> ~engines/.profile
	 echo 'export PATH="/usr/local/rbenv/bin:$PATH"' >> ~engines/.bashrc
	echo 'eval "$(rbenv init -)"' >> ~engines/.profile
	echo 'eval "$(rbenv init -)"' >> ~engines/.bashrc
	
	/usr/local/rbenv/plugins/ruby-build/install.sh 
	 
	/usr/local/rbenv/bin/rbenv install $RUBY_VER
	/usr/local/rbenv/bin/rbenv global $RUBY_VER
	echo "gem: --no-ri --no-rdoc" > ~/.gemrc
	
	/usr/local/rbenv/bin/rbenv rehash
	cp -rp  ~/.gemrc ~/.bashrc ~engines
	
 	~/.rbenv/shims/gem install multi_json rspec rubytree git 
		
	echo "Setup engines cron tab"
echo "*/10 * * * * /opt/engines/bin/engines.sh engine check_and_act all >>/opt/engines/logs/engines/restarts.log
*/10 * * * * /opt/engines/bin/engines.sh  service  check_and_act all >>/opt/engines/logs/services/restarts.log" >/tmp/ct
crontab -u engines /tmp/ct
rm /tmp/ct

#DHCP
 if test -f /etc/dhcp/dhclient.conf
 	then
		echo "prepend domain-name-servers 172.17.42.1;;" >> /etc/dhcp/dhclient.conf
		
		
	fi
	#temp while we wait for next dhcp renewal if using dhcp
	
echo "nameserver 172.17.42.1" >>  /etc/resolv.conf 


  }

#function make_dns_key {
#	rm -f ddns.private ddns.key
#	/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 128 -n HOST  -r /dev/urandom -n HOST DDNS_UPDATE
#	mv *private ddns.private
#	mv *key ddns.key
#}

function generate_keys {
echo "Generating system Keys"
keys=""
#keys=" nagios mgmt volmgr backup "




	for key in $keys
		do
		  ssh-keygen -q -N "" -f $key
	      cat $key.pub | awk '{ print $1 " " $2}' >$key.p
	      mv  $key.p $key.pub
	      mv $key /opt/engines/etc/keys/
	      cp $key.pub /opt/engines/system/images/03.serviceImages/$key/
	   done
	   
	   #FIXME add Intelligence to above loop ie use find

#	   cp mgmt.pub /opt/engines/system/images/04.systemApps/mgmt/
#	   cp nagios.pub /opt/engines/system/images/04.systemApps/nagios/
	     
#	ssh-keygen -q -N "" -f nagios
#	ssh-keygen -q -N "" -f mysql
#	ssh-keygen -q -N "" -f mgmt
#	ssh-keygen -q -N "" -f nginx
#	ssh-keygen -q -N "" -f backup
#	ssh-keygen -q -N "" -f pgsql
#	ssh-keygen -q -N "" -f mongo
#	
#	cat mongo pub | awk '{ print $1 " " $2}' > mongo.p
#	#remove host limits from pub key
#	cat pgsql.pub | awk '{ print $1 " " $2}' > pgsql.p
#	mv pgsql.p  pgsql.pub 
#	
#	cat nginx.pub | awk '{ print $1 " " $2}' > nginx.p
#	mv nginx.p  nginx.pub 
#	
#	cat nagios.pub | awk '{ print $1 " " $2}' > nagios.p
#	mv nagios.p  nagios.pub 
#	f
#	cat mgmt.pub | awk '{ print $1 " " $2}' > mgmt.p
#	mv mgmt.p  mgmt.pub 	
#	
#	cat mysql.pub | awk '{ print $1 " " $2}' > mysql.p
#	mv mysql.p  mysql.pub 	
#	
#	mv mongo mgmt nagios mysql nginx backup pgsql /opt/engines/etc/keys/
#	mv pgsql.pub /opt/engines/system/images/03.serviceImages/pgsql/
#	mv mysql.pub /opt/engines/system/images/03.serviceImages/mysql/
#	mv nagios.pub /opt/engines/system/images/04.systemApps/nagios/
#	mv nginx.pub /opt/engines/system/images/03.serviceImages/nginx/
#	mv mgmt.pub  /opt/engines/system/images/04.systemApps/mgmt/
#	mv backup.pub /opt/engines/system/images/03.serviceImages/backup
#	mv mongo.pub /opt/engines/system/images/03.serviceImages/mongo
#	
#	make_dns_key
	
#	key=`cat ddns.private |grep Key | cut -f2 -d" "`
	
#	while test `echo $key |grep -e / |wc -c` -gt 0
#		do
#			make_dns_key
#			key=`cat ddns.private |grep Key | cut -f2 -d" "`
#			echo DNS key $key
#		done
			
#	echo DNS key $key
	#cat /opt/engines/etc/dns/named.conf.default-zones.ad.tmpl| sed "/KEY_VALUE/s//"$key"/" > /opt/engines/system/images/03.serviceImages/dns/named.conf.default-zones.ad
	#cat /opt/engines/system/images/03.serviceImages/dns/named.conf.default-zones.ad.tmpl | sed "/KEY_VALUE/s//"$key"/" > /opt/engines/etc/dns/named.conf.default-zones
	#cp ddns.* /opt/engines/system/images/01.baseImages/01.base/
	#mv ddns.* /opt/engines/etc/dns/keys/
	
}

function make_dirs {
mkdir -p  /var/lib/engines/backup_paths
mkdir -p  /var/lib/engines/fs/
mkdir -p  /var/lib/engines/pgsql
mkdir -p  /var/lib/engines/mysql
mkdir -p  /var/lib/engines/mongo
mkdir -p  /var/log/engines/services/nginx/nginx
mkdir -p  /var/log/engines/services/backup
mkdir -p  /var/log/engines/services/mgmt
mkdir -p  /var/log/engines/services/pgsql/


mkdir -p  /var/log/engines/services/mysql/
mkdir -p  /var/log/engines/services/dns/
mkdir -p /var/log/engines/services/smtp/
mkdir -p /var/log/engines/containers/
mkdir -p /opt/engines/
mkdir -p  /var/lib/engines/mysql /var/log/engines/services/mysql/ /opt/engines/run/services/mysql_server/run/mysqld
mkdir -p /var/lib/engines/mysql /var/log/engines/services/mysql/ /opt/engines/run/services/mysql_server/run/mysqld
mkdir -p /var/lib/engines/psql /var/log/engines/services/psql	/opt/engines/run/services/pgsql_server/run/postgres
mkdir -p /var/log/engines/services/nginx /opt/engines/run/services/nginx/run/nginx
mkdir -p /var/lib/engines/mongo /var/log/engines/services/mongo	/opt/engines/run/services/mongo_server/run/mongo/
mkdir -p /opt/engines/run/services/dns/run/dns
mkdir -p /opt/engines/run/services/mysql_server/run/mysqld
mkdir -p /opt/engines/run/services/nginx/run/nginx/
mkdir -p /var/lib/engines/imap/lib
mkdir -p /var/lib/engines/imap/mail
mkdir -p /opt/engines/etc/syslog/conf/
mkdir -p /home/engines/db
touch /home/engines/db/production.sqlite3
touch /home/engines/db/development.sqlite3
mkdir -p /home/engines/deployment/deployed/
mkdir -p  /var/log/engines/services/ftp/proftpd
 mkdir -p  /var/log/engines/services/auth/ftp/
mkdir -p /opt/engines/etc/auth/keys/
mkdir -p  /opt/engines/etc/cron/tabs
mkdir -p /var/log/engines/services/cron
mkdir -p    /opt/engines/run/service_manager/
mkdir -p /home/engines/db/
touch  /home/engines/db/production.sqlite3
mkdir -p /home/engines/deployment/deployed/
mkdir -p  /opt/engines/etc/keys
mkdir -p /var/log/engines/services/syslog/rmt
mkdir -p /var/log/engines/services/email/apache2
mkdir -p /opt/engines/etc/backup/configs
mkdir -p /opt/engines/etc/ssl/imap
mkdir -p /opt/engines/etc/ssl/smtp
mkdir -p /opt/engines/etc/ssl/psql/
mkdir -p /opt/engines/etc/smtp
mkdir -p /opt/engines/ssh/keys/services/
cp -r /opt/engines/etc/ssl/certs /opt/engines/etc/ssl/smtp/
cp -r /opt/engines/etc/ssl/keys /opt/engines/etc/ssl/smtp/
cp -r /opt/engines/etc/ssl/certs /opt/engines/etc/ssl/imap/
cp -r /opt/engines/etc/ssl/keys /opt/engines/etc/ssl/imap/
cp -r /opt/engines/etc/ssl/certs /opt/engines/etc/ssl/psql/
cp -r /opt/engines/etc/ssl/keys /opt/engines/etc/ssl/psql/private
}

function set_permissions {
echo "Setting directory and file permissions"
	chown -R engines /opt/engines/ /var/lib/engines ~engines/  /var/log/engines
	chown -R 22006.22006  /var/lib/engines/mysql /var/log/engines/services/mysql/ /opt/engines/run/services/mysql_server/run/mysqld
	chown -R 22002.22002	/var/lib/engines/psql /var/log/engines/services/psql	/opt/engines/run/services/pgsql_server/run/postgres
	chown -R 22005.22005 /var/log/engines/services/nginx /opt/engines/run/services/nginx/run/nginx
    chown -R 22008.22008 /var/lib/engines/mongo /var/log/engines/services/mongo	/opt/engines/run/services/mongo_server/run/mongo/
	chown -R 22009.22009 /opt/engines/run/services/dns/run/dns
	chown -R 22010 /var/log/engines/services/ftp
	 
	chown  engines   /opt/engines/etc/syslog/conf/
	chown  22012 -R  /var/log/engines/services/syslog
	chown  22012 /var/log/engines/services/syslog

	chown 22005 /opt/engines/run/services/nginx/run/nginx/
	chown 21000  /home/engines/db/production.sqlite3
	chown 21000  /home/engines/db/development.sqlite3
	chown -R 21000 /opt/engines/etc/keys
	chown -R 21000 /home/engines/db/
	chown -R 21000 /opt/engines/run/service_manager/
	chown -R 21000 /home/engines/deployment/deployed/
	chown -R 22013 /var/lib/engines/imap
	chown -R 22014  /var/lib/engines/imap/mail
	chown -R 22013 /opt/engines/etc/ssl/imap
	chmod og-rw -R /opt/engines/etc/ssl/imap
	chown -R 22002 /opt/engines/etc/ssl/psql
	chmod og-rw -R /opt/engines/etc/ssl/psql
	chown 22003 -R /opt/engines/etc/smtp
	chown 22017 -R  /opt/engines/ssh/keys/services/
	
	 chown 22003 -R /var/log/engines/services/email/
	 chown  -R 22015 /opt/engines/etc/backup/
	chown 22015 /var/lib/engines/backup_paths/
	chown 22017 -R /var/log/engines/services/auth/
	chown 22017 -R  /opt/engines/etc/auth/keys/
	}

function set_os_flavor {
echo "Configuring OS Specific Dockerfiles"
	if test `uname -v |grep -i ubuntu |wc -c` -gt 0
	then
		files=`find /opt/engines/system/images/ -name "*.ubuntu"`
			for file in $files
				do
					new_name=`echo $file | sed "/.ubuntu/s///"`
					rm $new_name
					mv $file $new_name
				done
	elif test `uname -v |grep -i debian  |wc -c` -gt 0
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
echo "Creating and starting Engines Services"
	 /opt/engines/bin/engines.rb service create dns
	sleep 30
	 /opt/engines/bin/engines.rb service create mysql_server
	 /opt/engines/bin/engines.rb service create nginx
	
	 /opt/engines/bin/eservices create 
	
}
function remove_services {
echo "Creating and startingg Engines OS Services"

docker stop cAdvisor mysql_server backup nginx dns mgmt
docker rm cAdvisor mysql_server backup nginx dns mgmt
	
}
function generate_ssl {
echo "Generating Self Signed Cert"

mkdir -p /opt/engines/etc/ssl/keys/
mkdir -p /opt/engines/etc/ssl/certs/

openssl genrsa -des3 -out server.key 2048
 openssl rsa -in server.key -out server.key.insecure
  mv server.key server.key.secure
  mv server.key.insecure server.key
  openssl req -new -key server.key -out server.csr
  openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
  mv server.key /opt/engines/etc/ssl/keys/engines.key
  mv server.crt /opt/engines/etc/ssl/certs/engines.crt
   
   #Initial Certs for nginx are the mgmt certs
   mkdir -p /opt/engines/etc/nginx/ssl/ /opt/engines/etc/nginx/ssl/
   cp -rp /opt/engines/etc/ssl/certs  /opt/engines/etc/nginx/ssl/
   cp -rp /opt/engines/etc/ssl/keys   /opt/engines/etc/nginx/ssl/
   
   rm server.csr  server.key.secure
  
}

function setup_mgmt_git {
echo "Seeding Mgmt Application source from repository"
mkdir -p /opt/engines/system/images/04.systemApps/mgmt/home/app
	 cd /opt/engines/system/images/04.systemApps/mgmt/home/app
	  if test ! -f .git/config
		then
			git init
			
			git remote add -t alpha origin 	https://github.com/EnginesOS/SystemGui.git
			git fetch 
		fi
#			echo '[core]
#				        repositoryformatversion = 0
#				        filemode = true
#				        bare = false
#				        logallrefupdates = true
#				[branch "master"]
#				[remote "origin"]
#				        url = https://github.com/EnginesOS/SystemGui.git
#				        fetch = +refs/heads/*:refs/remotes/origin/*
#				[branch "master"]
#				        remote = origin
#				        merge = refs/heads/master
#				' > .git/config		
#		fi
#		git pull
}
