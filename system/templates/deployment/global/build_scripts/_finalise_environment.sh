#!/bin/bash


	grep :$data_gid: /etc/group >/dev/null
	if test $? -ne 0
	 then
		groupadd -g $data_gid writegrp 
	fi
echo "	id $ContUser | grep $data_gid '"
 id $ContUser | grep $data_gid 
 
	id $ContUser | grep $data_gid >/dev/null	
	if test $? -ne 0
	 then
	echo "add contuser to data group"
		usermod -G $data_gid -a $ContUser
	fi
	chown -R  $data_uid.$data_gid  /home/app
	
	 mkdir -p ~$ContUser/.ssh
     chown -R $ContUser ~$ContUser/.ssh
 
 	
	if test -f /build_scripts/finalise_environment.sh
		then	
			/build_scripts/finalise_environment.sh
	fi
	
	if ! test -z "$VOLDIR"
	then
		ln -s $VOLDIR /data
	fi
	
chown -R  $ContUser $HOME
#chmod g-w $HOME