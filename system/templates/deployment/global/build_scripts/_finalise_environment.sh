#!/bin/sh


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

	 mkdir -p ~$ContUser/.ssh
	chown -R  $ContUser $HOME
 
 	
	if test -f /build_scripts/finalise_environment.sh
		then
			echo "running finalise_environment.sh"
			/build_scripts/finalise_environment.sh
	fi
	
	if ! test -z "$VOLDIR"
	then
		ln -s $VOLDIR /data
	fi
	
	if test -f /home/database_seed
	 then
	  service_path=`head -1 /home/database_seed | sed "/#/s///"`
	  cat /home/database_seed | grep -v  '^#' | /home/engines/services/$service_path/restore.sh	  
	 fi


    

#chmod g-w $HOME