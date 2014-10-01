#!/bin/bash


cd /home/app
 . /etc/rvmrc 
rvm  --default use ruby-2.1.2

git pull

cat /home/app/config/environments/production.rb |sed "/config.serve_static_assets = false/s//config.serve_static_assets = true/" >/tmp/t
cp /tmp/t /home/app/config/environments/production.rb


bundle install --path vendor/bundle

bundle exec rake db:migrate 
# RAILS_ENV=production 
bundle exec rake db:populate 
# RAILS_ENV=production 
bundle exec rake assets:precompile 
# RAILS_ENV=production 
bundle exec rake generate_secret_token 
# RAILS_ENV=production 

	if test -f /opt/engos/etc/ssl/keys/engines.key -a  -f /opt/engos/etc/ssl/certs/engines.crt 
	then
	 env SECRET_KEY_BASE=`bundle exec rake secret` 	 bundle exec thin -p 8000   --ssl --ssl-key-file /opt/engos/etc/ssl/keys/engines.key --ssl-cert-file /opt/engos/etc/ssl/certs/engines.crt start
	else
	 env SECRET_KEY_BASE=`bundle exec rake secret` 	bundle exec thin -p 8000   start
	fi
