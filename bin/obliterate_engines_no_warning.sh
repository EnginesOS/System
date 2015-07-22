#!/bin/sh

echo "15 seconds until destruction with no visual countdown starting now"
sleep 20
if test -d EnginesInstaller
	then
		service docker stop
		rm -r /var/lib/engines
		rm -r /var/log/engines
		rm -r /opt/engines
		 rm -r /var/spool/cron/crontabs/engines
		apt-get -y remove lxc-docker
		apt-get -y autoremove
		userdel -r  engines

		cat /etc/rc.local |grep -v engines >/tmp/.local
		cp /tmp/.local   /etc/rc.local
		 rm -r EnginesInstaller
		groupdel containers
				groupdel engines
		rm -rf /usr/local/rbenv
		 rm /etc/network/if-up.d/set_ip.sh 
		rm -r /home/engines/.ssh
		 docker rm `docker ps -a |awk '{print $1}' `
		rm -fr /home/engines/.rbenv
    else
      echo Script must be run as root from the dir that contains EnginesInstaller
fi