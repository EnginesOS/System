#!/bin/bash
echo Starting Engines System

. ~/.bashrc

if test -f /opt/engines/run/system/flags/run_post_system_update
 then 
  if test -f /opt/engines/system/scripts/ssh/sudo/post_system_update_boot.sh
   then
  	sudo -n /opt/engines/system/scripts/ssh/sudo/post_system_update_boot.sh
   fi
 fi

rm `find /opt/engines/run -name lock` 

/opt/engines/system/scripts/system/rotate_system_log.sh

if test -f ~/.complete_update
then
   /opt/engines/system/scripts/update/finish_update.sh  
fi 

/opt/engines/system/scripts/startup/set_ip.sh
release=`cat /opt/engines/release`

CONTROL_IP=`/opt/engines/bin/system_ip.sh`
export CONTROL_IP

DOCKER_IP=`ifconfig docker0 |grep "inet addr" |cut -f2 -d: |cut -f1 -d" "`
export DOCKER_IP

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

	grep dhcp /etc/network/interfaces
	 if test $? -eq 0
	  then
	 	/opt/engines/system/scripts/refresh_local_hosted_domains.sh `/opt/engines/bin/system_ip.sh` 
	  fi

if test -f /usr/bin/pulseaudio
 then
  pulseaudio --check
   if test $? -ne 0
    then
 	 /usr/bin/pulseaudio -D
    fi
 fi
 

if test `/opt/engines/bin/system_service.rb registry state` = nocontainer
 then
	/opt/engines/bin/system_service.rb registry create
	/opt/engines/bin/system_service.rb registry wait_for create 60
	/opt/engines/bin/system_service.rb registry start
 elif test `/opt/engines/bin/system_service.rb registry state` = stopped
  then
	/opt/engines/bin/system_service.rb registry start
  else
  	/opt/engines/bin/system_service.rb registry start
  fi
  /opt/engines/bin/system_service.rb registry wait_for start 30
/opt/engines/bin/system_service.rb registry wait_for_startup 60

if test `/opt/engines/bin/system_service.rb system state` = nocontainer
 then
	/opt/engines/bin/system_service.rb system create
	/opt/engines/bin/system_service.rb system wait_for create 60
	/opt/engines/bin/system_service.rb system create
 elif test `/opt/engines/bin/system_service.rb system state` = stopped
  then
	/opt/engines/bin/system_service.rb system start
 fi
  /opt/engines/bin/system_service.rb system wait_for start 30
/opt/engines/bin/system_service.rb system wait_for_startup 60


/opt/engines/bin/engines service dns start 
/opt/engines/bin/engines service dns wait_for start 60

/opt/engines/bin/engines service syslog start

/opt/engines/bin/engines service auth start
/opt/engines/bin/engines service auth wait_for start 60

/opt/engines/bin/engines service mysqld start
/opt/engines/bin/engines service mysqld wait_for start 60

/opt/engines/bin/engines service ldap start
/opt/engines/bin/engines service ldap wait_for start 60
/opt/engines/bin/engines service wap start

rm /opt/engines/run/system/flags/system_starting

/opt/engines/bin/engines containers check_and_act 


if test -f ~/.complete_install
then
   /opt/engines/system/install/complete_install.sh 
fi 


