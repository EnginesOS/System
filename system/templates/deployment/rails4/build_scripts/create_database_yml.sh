#!/bin/sh

	if test -d config 
		then 
			config_dir=config 
		else 
			config_dir="."
	fi 
	
#	echo "#Generated by Engines builder" > $config_dir/database.yml
#	echo "login: &login" >> $config_dir/database.yml
#	echo "  adapter: $dbflavor" >> $config_dir/database.yml
#	echo "  host: localhost">> $config_dir/database.yml
#	echo "  username: root">> $config_dir/database.yml
#	echo "  password:">> $config_dir/database.yml
#	echo "development:" >> $config_dir/database.yml
#	echo "  database: ${dbname}_dev" >> $config_dir/database.yml 
#	echo "  <<: *login" >> $config_dir/database.yml 
#	echo "test:" >> $config_dir/database.yml
#	echo "  database: ${dbname}_tests" >> $config_dir/database.yml
#	echo "  <<: *login" >> $config_dir/database.yml
#	echo "production:">> $config_dir/database.yml
#	echo "  database: $dbname ">> $config_dir/database.yml
#	echo "  <<: *login" >> $config_dir/database.yml 	
#	echo "wrote  $config_dir/database.yml"	
#	echo in `pwd`


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