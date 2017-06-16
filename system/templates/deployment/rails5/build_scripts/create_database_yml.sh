#!/bin/sh

if test -d config 
 then 
	 config_dir=config 
else 
	 config_dir="."
fi 
	

echo "#Generated by Engines builder
production:
 adapter: $rails_flavor
 database: $dbname 
 host: $dbhost
 username: $dbuser
 password: $dbpasswd
" > $config_dir/database.yml 	

echo wrote  $config_dir/database.yml	
echo `pwd`