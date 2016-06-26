#!/bin/bash
grep follow_sta ~/.bashrc  
if test $? -ne 0
then
	cat ~/.bashrc  |grep -v follow_star  >/tmp/.t
	mv /tmp/.t ~/.bashrc
fi

. ~/.bashrc

if test -f  ~/.complete_update
then
   /opt/engines/system/scripts/update/finish_update.sh  
fi 

release=`cat /opt/engines/release`


CONTROL_IP=`/opt/engines/bin/system_ip.sh`
export CONTROL_IP

sudo -n /opt/engines/system/scripts/startup/sudo/_check_local-kv.sh  

if test -f /opt/engines/system/startup/flags/replace_keys
 then
  /opt/engines/system/scripts/startup/replace_keys.sh 
  rm /opt/engines/system/startup/flags/replace_keys 
 fi



echo Clearing Flags
cp /etc/os-release /opt/engines/etc/os-release-host 

rm -f /opt/engines/run/system/flags/reboot_required  
rm -f /opt/engines/run/system/flags/engines_rebooting  
rm -f /opt/engines/run/system/flags/building_params  
rm -f /opt/engines/run/system/flags/update_engines_running 


#rm -f /opt/engines/run/system/flags/


	grep dhcp /etc/network/interfaces
	 if test $? -eq 0
	  then
	 		/opt/engines/system/scripts/refresh_local_hosted_domains.sh `/opt/engines/system/scripts/get_ip.sh` 
	  fi





if test -f /usr/bin/pulseaudio
 then
 	/usr/bin/pulseaudio -D
 fi
 
 	


docker start registry
#ruby /opt/engines/bin/system_service.rb registry start
sleep 25
if test `/opt/engines/bin/system_service.rb system state` = \"nocontainer\"
 then
	/opt/engines/bin/system_service.rb system create
 elif test `/opt/engines/bin/system_service.rb system state` = \"stopped\"
  then
	/opt/engines/bin/system_service.rb system start
  fi
  
  while ! test -f /opt/engines/run/system_services/system/run/flags/startup_complete
  do 
  	sleep 5
  	count=`expr $count + 5`
  		if test $count -gt 120
  		 then
  		  echo "ERROR failed to start system "
  		fi
  done 
 
/opt/engines/bin/engines_tool system login test test
  
  
#pull dns prior to start so download time (if any) is not included in the start timeout below
docker pull engines/dns:$release 

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



/opt/engines/bin/engines_tool service  mysql_server start
/opt/engines/bin/engines_tool service nginx start


#this dance ensures auth gets pub key from ftp 
#really only needs to happen firts time ftp is enabled
 /opt/engines/bin/engines_tool service ftp start
 /opt/engines/bin/engines_tool service auth start
   /opt/engines/bin/engines_tool service ftp stop
   /opt/engines/bin/engines_tool service ftp start



/opt/engines/bin/engines_tool containers check_and_act 


if test -f  ~/.complete_install
then
   /opt/engines/system/install/complete_install.sh 
fi 


