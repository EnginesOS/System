#!/bin/bash
sites=`ls /etc/nginx/sites-enabled/ |grep -v default`

	for site in $sites
		do
			grep server_name /etc/nginx/sites-enabled/$site  |sed "/;/s///" |  sed "/.*server_name/s///"
		done

