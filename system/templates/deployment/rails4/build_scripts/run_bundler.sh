#!/bin/bash

 echo "Rails.application.routes.default_url_options[:host] = '$fqdn'" >> config/environment.rb

if ! test -f /tmp/.bundled
 then
	if test -f Gemfile 
		then 
			cat /home/app/Gemfile | egrep -v "thin|puma" > /tmp/Gemfile
			cp /tmp/Gemfile /home/app/Gemfile
	 		/usr/local/rbenv/shims/bundle config build.nokogiri --use-system-libraries
	 		/usr/local/rbenv/shims/bundle --standalone  --no-rdoc --no-ri  install
	 fi
	 
	   
fi	 