#!/bin/bash
/usr/bin/mysql_install_db
#echo "CREATE USER 'rma'@'localhost';  grant SELECT,INSERT,UPdate,create,SHOW DATABASES,CREATE USER ON *.* TO  'rma'@'localhost'  WITH GRANT OPTION; " |mysql -u root
echo "CREATE USER 'rma'@'localhost';  grant all ON *.* TO  'rma'@'localhost'  WITH GRANT OPTION; " |mysql -u root
