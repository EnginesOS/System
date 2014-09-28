#!/bin/bash


cd /home/app
 . /etc/rvmrc 
rvm  --default use ruby-2.1.2

git pull


bundle install --path vendor/bundle

bundle exec rake db:migrate
bundle exec rake db:populate

	if test -f /opt/engos/etc/ssl/keys/engines.key -a  -f /opt/engos/etc/ssl/certs/engines.crt 
	then
		bundle exec thin -p 8000   --ssl --ssl-key-file /opt/engos/etc/ssl/keys/engines.key --ssl-cert-file /opt/engos/etc/ssl/certs/engines.crt start
	else
		bundle exec thin -p 8000   start
	fi
