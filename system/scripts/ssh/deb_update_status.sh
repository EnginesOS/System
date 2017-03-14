#

sudo -n /opt/engines/system/scripts/ssh/sudo/_apt-get_update.sh 

updates=`/usr/lib/update-notifier/apt-check  --human-readable `

update_cnt=`echo $updates | grep    "packages" | awk '{print $1}'  `

if  test 0 -eq $update_cnt
 then
	  echo Upto date  	
	  rm /opt/engines/run/system/flags/base_os_update_pending
	  exit 0
 fi

 echo $updates >  /opt/engines/run/system/flags/base_os_update_pending
 
 exit 127
 

