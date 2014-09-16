 #/bin/bash
 
 cat /etc/rc.local | sed "/exit.*/s/su -l dockuser \/opt\/engos\/bin\/mgmt_startup.sh/" >> /tmp/rc.local
 echo "exit 0"  >> /tmp/rc.local
 cp /tmp/rc.local /etc/rc.local
 rm  /tmp/rc.local
 chmod u+x  /etc/rc.local
 
 echo "DOCKER_OPTS=\"--dns  172.17.42.1 --dns 8.8.8.8\" " >> /etc/default/docker 
 
 mkdir -p /opt/engos
 
 apt-get install apt-transport-https
 echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
 apt-get -y update
 apt-get -y install lxc-docker
 bind=`service bind9 status  |grep unrecognized | wc -l`
 apt-get -y install imagemagick cmake bind9 dc mysql-client libmysqlclient-dev unzip wget
 
 #Only Remove if not present
 if test $bind -eq 0
 	then
 		update-rc.d bind9 remove
 	fi
 
 #Kludge should not be a static but a specified or atleaqst checked id
 adduser --uid 21000 --ingroup docker --home /home/dockuser --disabled-password dockuser
 
echo "PATH=\"/opt/engos/bin:$PATH\"" >>~dockuser/.profile 

\curl -L https://get.rvm.io | bash -s stable 
echo " /etc/profile.d/rvm.sh" >> ~dockuser/.login 


/usr/local/rvm/bin/rvm install ruby-2.1.1




mkdir -p /opt/engos/
mkdir -p /var/lib/engos

cd /opt/engos
git init 

echo '[core]\
        repositoryformatversion = 0\
        filemode = true\
        bare = false\
        logallrefupdates = true\
[branch \"master\"]\
[remote \"origin\"]\
        url = https://github.com/EnginesOS/System\
        fetch = +refs/heads/*:refs/remotes/origin/*\
[branch \"master\"]\
        remote = origin\
        merge = refs/heads/master\
' > .git/config
git pull

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

chown -R dockuser /opt/engos/ /var/lib/engos

su -l dockuser /opt/engos/bin/buildimages.sh
su -l dockuser /opt/engos/bin/mgmt_startup.sh 

  

 