#!/bin/bash
/opt/engines/bin/set_ip.sh

docker_db_state=`strings /var/lib/docker/network/files/local-kv.db`

	if test -z "$docker_db_state"
		then
			rm /var/lib/docker/network/files/local-kv.db
	fi
 
 chmod oug-w /opt/engines/etc/net/management

echo Clearing Flags
cp /etc/os-release /opt/engines/etc/os-release-host
rm -f /opt/engines/run/system/flags/reboot_required 
rm -f /opt/engines/run/system/flags/engines_rebooting 
rm -f /opt/engines/run/system/flags/building_params 
cp /etc/os-release /opt/engines/etc/os-release-host
#rm -f /opt/engines/run/system/flags/
/opt/engines/bin/eservice start dns

	grep dhcp /etc/network/interfaces
	 if test $? -eq 0
	  then
	 		/opt/engines/scripts/_refresh_local_hosted_domains.sh `/opt/engines/bin/get_ip.sh`
	  fi
docker start registry
eservice start dns

docker_ip=`/sbin/ifconfig docker0 |grep "inet add" |cut -f2 -d: | cut -f1 -d" "`
rm -f /opt/engines/etc/net/management

#FIXME below is a kludge

if test -z "$docker_ip
 then
   sleep 5
       docker_ip=`/sbin/ifconfig docker0 |grep "inet add" |cut -f2 -d: | cut -f1 -d" "`
 fi
 
 if test -z "$docker_ip
 then
  echo Panic no IP address on docker0
  exit
  else
   echo -n $docker_ip > /opt/engines/etc/net/management
  fi
 

/opt/engines/bin/eservices check_and_act 

/opt/engines/bin/engines check_and_act 

if test -f  ~/.complete_install
then
   /opt/engines/installers/finish_install.sh
fi 

if test -f  ~/.complete_update
then
   /opt/engines/updaters/finish_update.sh
fi 

