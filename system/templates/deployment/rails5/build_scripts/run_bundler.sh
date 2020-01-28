#!/bin/sh
#could be dynamic
 echo "Rails.application.routes.default_url_options[:host] = '$fqdn'" >> /home/app/config/environment.rb

if test -f Gemfile 
	  then 
	   bundle --standalone install	   
fi	 