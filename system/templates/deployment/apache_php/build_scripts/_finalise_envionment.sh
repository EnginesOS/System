#!/bin/bash

    groupadd -g $data_gid writegrp
	usermod -a -G $data_gid www-data
	chown -R  $data_uid.$data_gid  /home/app/  /home/local/
	
	if test -f /build_scripts/finalise_environment.sh
		then	
			/build_scripts/finalise_environment.sh
	fi