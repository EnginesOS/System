#!/bin/bash

if test -f  ~/.complete_update
then
   /opt/engines/bin/finish_update.sh  2>&1  /var/log/engine/last_start.log 
fi 


/opt/engines/bin/set_ip.sh  2>&1  /var/log/engine/last_start.log 

sudo -n /opt/engines/scripts/_check_local-kv.sh  2>&1  /var/log/engine/last_start.log 

if test -f /opt/engines/system/flags/replace_keys
 then
  /opt/engines/bin/replace_keys.sh  2>&1  /var/log/engine/last_start.log
  rm /opt/engines/system/flags/replace_keys  2>&1  /var/log/engine/last_start.log
 fi


 chmod oug-w /opt/engines/etc/net/management  2>&1  /var/log/engine/last_start.log 

echo Clearing Flags
cp /etc/os-release /opt/engines/etc/os-release-host  2>&1  /var/log/engine/last_start.log

rm -f /opt/engines/run/system/flags/reboot_required   2>&1  /var/log/engine/last_start.log
rm -f /opt/engines/run/system/flags/engines_rebooting   2>&1  /var/log/engine/last_start.log
rm -f /opt/engines/run/system/flags/building_params   2>&1  /var/log/engine/last_start.log
rm -f /opt/engines/run/system/flags/update_engines_running  2>&1  /var/log/engine/last_start.log

cp /etc/os-release /opt/engines/etc/os-release-host  2>&1  /var/log/engine/last_start.log
#rm -f /opt/engines/run/system/flags/


	grep dhcp /etc/network/interfaces
	 if test $? -eq 0
	  then
	 		/opt/engines/scripts/_refresh_local_hosted_domains.sh `/opt/engines/bin/get_ip.sh`  2>&1  /var/log/engine/last_start.log
	  fi

docker_ip=`/sbin/ifconfig docker0 |grep "inet add" |cut -f2 -d: | cut -f1 -d" "`
rm -f /opt/engines/etc/net/management  2>&1  /var/log/engine/last_start.log

#FIXME below is a kludge

if test -z "$docker_ip"
 then
   sleep 5 
       docker_ip=`/sbin/ifconfig docker0 |grep "inet add" |cut -f2 -d: | cut -f1 -d" "`  2>&1  /var/log/engine/last_start.log 
 fi
 
 if test -z "$docker_ip"
 then
  echo Panic no IP address on docker0
  exit
  else
   echo -n $docker_ip  2>&1 /opt/engines/etc/net/management
  fi

docker start registry  2>&1  /var/log/engine/last_start.log
/opt/engines/bin/eservice start dns  2>&1  /var/log/engine/last_start.log
#FIXMe use startup complete flag
sleep 10
/opt/engines/bin/eservice start mysql_server  2>&1  /var/log/engine/last_start.log

/opt/engines/bin/eservice start nginx  2>&1  /var/log/engine/last_start.log

#this dance ensures auth gets pub key from ftp  2>&1  /var/log/engine/last_start.log
#really only needs to happen firts time ftp is enabled 
/opt/engines/bin/eservice start ftp  2>&1  /var/log/engine/last_start.log
/opt/engines/bin/eservice start auth  2>&1  /var/log/engine/last_start.log
# restart ftp in case dont have access keys from auth
/opt/engines/bin/eservice stop ftp  2>&1  /var/log/engine/last_start.log
/opt/engines/bin/eservice start ftp  2>&1  /var/log/engine/last_start.log



/opt/engines/bin/eservices check_and_act  2>&1  /var/log/engine/last_start.log

/opt/engines/bin/engines check_and_act   2>&1  /var/log/engine/last_start.log

if test -f  ~/.complete_install
then
   /opt/engines/system/install/complete_install.sh  2>&1  /var/log/engine/last_start.log
fi 


