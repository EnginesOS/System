#!/bin/bash


	grep :$data_gid: /etc/group >/dev/null
	if test $? -ne 0
	 then
		groupadd -g $data_gid writegrp
	fi
	
	id www-data | grep $data_gid >/dev/null	
	if test $? -ne 0
	 then
		usermod -G $data_gid www-data
	fi
	chown -R  $data_uid.$data_gid  /home/app
	
	if test -f /build_scripts/finalise_environment.sh
		then	
			/build_scripts/finalise_environment.sh
	fi