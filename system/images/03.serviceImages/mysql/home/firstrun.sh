#!/bin/bash
pass="pass"




 if ! test -f /var/lib/mysql/mysql
 then
 	cd /home/mysql
	/usr/bin/mysql_install_db
	

	/etc/init.d/mysql start
	echo "CREATE USER 'rma'@'localhost';  grant all ON *.* TO  'rma'@'localhost'  WITH GRANT OPTION; " |mysql -u root
	echo "CREATE USER 'root'@'%' identified by '$pass';  grant all ON *.* TO  'root'@'%'  WITH GRANT OPTION; "
	echo "CREATE USER 'root'@'%' identified by '$pass';  grant all ON *.* TO  'root'@'%'  WITH GRANT OPTION; " |mysql -u root
	 /usr/bin/mysqladmin -u root  password '$pass'
	 /etc/init.d/mysql stop
 fi
	 
