#!/bin/bash

if ! test -f /tmp/.bundled
 then
	if test -f Gemfile 
		then 
			cat /home/app/Gemfile | egrep -v "thin|puma" > /tmp/Gemfile
			cp /tmp/Gemfile /home/app/Gemfile
	 		/usr/local/rbenv/shims/bundle config build.nokogiri --use-system-libraries
	 		/usr/local/rbenv/shims/bundle --standalone install
	 fi  
fi	 