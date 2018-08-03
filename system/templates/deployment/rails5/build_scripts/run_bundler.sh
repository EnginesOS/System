#!/bin/bash

 echo "Rails.application.routes.default_url_options[:host] = '$fqdn'" >> config/environment.rb

if ! test -f /tmp/.bundled
 then
	if test -f Gemfile 
	  then 
	   cat /home/app/Gemfile | egrep -v "thin|puma" > /tmp/Gemfile
	   cp /tmp/Gemfile /home/app/Gemfile
	  # bundle config build.nokogiri --use-system-libraries  
	   bundle --standalone install
	fi	   
fi	 