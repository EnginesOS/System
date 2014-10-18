#!/bin/bash
PATH="/usr/local/rbenv/bin:$PATH" 

cd /home/app


/usr/local/rbenv/shims/gem install git bundle oink
/usr/local/rbenv/shims/gem install vmstat

git pull

#cat /home/app/config/environments/production.rb |sed "/config.serve_static_assets = false/s//config.serve_static_assets = true/" >/tmp/t
#cp /tmp/t /home/app/config/environments/production.rb


/usr/local/rbenv/shims/bundle install

/usr/local/rbenv/shims/bundle exec rake db:migrate 
# RAILS_ENV=production 
/usr/local/rbenv/shims/bundle exec rake db:populate 
# RAILS_ENV=production 
/usr/local/rbenv/shims/bundle exec rake assets:precompile 
# RAILS_ENV=production 
/usr/local/rbenv/shims/bundle exec rake generate_secret_token 
# RAILS_ENV=production 

mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

	if test -f /opt/engos/etc/ssl/keys/engines.key -a  -f /opt/engos/etc/ssl/certs/engines.crt 
	then
	 env SECRET_KEY_BASE=`bundle exec rake secret` 	/usr/local/rbenv/shims/bundle exec thin -p 8000   --ssl --ssl-key-file /opt/engos/etc/ssl/keys/engines.key --ssl-cert-file /opt/engos/etc/ssl/certs/engines.crt start
	else
	 env SECRET_KEY_BASE=`bundle exec rake secret` 	/usr/local/rbenv/shims/bundle exec thin -p 8000   start
	fi
	
rm /engines/var/run/startup_complete