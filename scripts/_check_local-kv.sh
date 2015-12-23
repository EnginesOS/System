#!/bin/sh

docker_db_state=`strings /var/lib/docker/network/files/local-kv.db`

	if test -z "$docker_db_state"
		then
			rm /var/lib/docker/network/files/local-kv.db
	fi
 