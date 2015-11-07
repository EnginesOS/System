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
	chown -R  $data_uid.$data_gid  ./

	mkdir -p /home/app/tmp/ /home/app/public/cache/ /home/app/public/assets /run/apache2
	chown www-data.$data_gid -R public
	chown www-data.$data_gid -R /home/app/tmp/ /run/apache2

	mkdir -p log
	chmod -R g+w  log

		if test -d db
			then 
				chmod -R g+w  db
		fi