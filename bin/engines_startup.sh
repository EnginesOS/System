#!/bin/bash
grep follow_sta r~/.bashrc  
if test $? -ne 0
then
	cat ~/.bashrc  |grep -v follow_star  >/tmp/.t
	mv /tmp/.t ~/.bashrc
fi

. ~/.bashrc

if test -f  ~/.complete_update
then
   /opt/engines/bin/finish_update.sh  
fi 

release=`cat /opt/engines/release`

/opt/engines/bin/set_ip.sh  

sudo -n /opt/engines/scripts/_check_local-kv.sh  

if test -f /opt/engines/system/flags/replace_keys
 then
  /opt/engines/bin/replace_keys.sh 
  rm /opt/engines/system/flags/replace_keys 
 fi


 chmod oug-w /opt/engines/etc/net/management  

echo Clearing Flags
cp /etc/os-release /opt/engines/etc/os-release-host 

rm -f /opt/engines/run/system/flags/reboot_required  
rm -f /opt/engines/run/system/flags/engines_rebooting  
rm -f /opt/engines/run/system/flags/building_params  
rm -f /opt/engines/run/system/flags/update_engines_running 

cp /etc/os-release /opt/engines/etc/os-release-host 
#rm -f /opt/engines/run/system/flags/


	grep dhcp /etc/network/interfaces
	 if test $? -eq 0
	  then
	 		/opt/engines/scripts/_refresh_local_hosted_domains.sh `/opt/engines/bin/get_ip.sh` 
	  fi

docker_ip=`/sbin/ifconfig docker0 |grep "inet add" |cut -f2 -d: | cut -f1 -d" "`
rm -f /opt/engines/etc/net/management 

#FIXME below is a kludge

if test -z "$docker_ip"
 then
   sleep 5 
       docker_ip=`/sbin/ifconfig docker0 |grep "inet add" |cut -f2 -d: | cut -f1 -d" "`  
 fi
 
 if test -z "$docker_ip"
 then
  echo Panic no IP address on docker0
  exit
  else
   echo -n $docker_ip  2>&1 /opt/engines/etc/net/management
  fi


if test -f /usr/bin/pulseaudio
 then
 	/usr/bin/pulseaudio -D
 fi
 
 	


docker start registry
#ruby /opt/engines/bin/system_service.rb registry start
sleep 25
if test `ruby /opt/engines/bin/system_service.rb system state` = \"nocontainer\"
 then
	ruby /opt/engines/bin/system_service.rb system create
 elif test `ruby /opt/engines/bin/system_service.rb system state` = \"stopped\"
  then
	ruby /opt/engines/bin/system_service.rb system start
  fi
  
  /opt/engines/bin/engines_tool system login test test
  
#pull dns prior to start so download time (if any) is not included in the start timeout below
docker pull engines/dns:$release 

#/opt/engines/bin/eservice start dns
/opt/engines/bin/engines_tool service dns start 
count=0

 while ! test -f /opt/engines/run/services/dns/run/flags/startup_complete
  do 
  	sleep 5
  	count=`expr $count + 5`
  		if test $count -gt 120
  		 then
  		  echo "ERROR failed to start DNS "
  		fi
  done 


#/opt/engines/bin/eservice start mysql_server 
/opt/engines/bin/engines_tool service  mysql_server start
/opt/engines/bin/engines_tool service nginx start
#/opt/engines/bin/eservice start nginx 

#this dance ensures auth gets pub key from ftp 
#really only needs to happen firts time ftp is enabled
 /opt/engines/bin/engines_tool service ftp start
 /opt/engines/bin/engines_tool service auth start
   /opt/engines/bin/engines_tool service ftp stop
   /opt/engines/bin/engines_tool service ftp start
#/opt/engines/bin/eservice start ftp 
#/opt/engines/bin/eservice start auth 
# restart ftp in case dont have access keys from auth
#/opt/engines/bin/eservice stop ftp 
#/opt/engines/bin/eservice start ftp 



#/opt/engines/bin/eservices check_and_act 

#/opt/engines/bin/engines check_and_act  

if test -f  ~/.complete_install
then
   /opt/engines/system/install/complete_install.sh 
fi 


