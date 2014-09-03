#!/bin/bash
/usr/bin/mysql_install_db
cat /etc/mysql/my.cnf |sed "/127.0.0.1/s//0.0.0.0/" >/etc/mysql/my.cnf.sed
mv /etc/mysql/my.cnf.sed /etc/mysql/my.cnf
/etc/init.d/mysql start
#echo "CREATE USER 'rma'@'localhost';  grant SELECT,INSERT,UPdate,create,SHOW DATABASES,CREATE USER ON *.* TO  'rma'@'localhost'  WITH GRANT OPTION; " |mysql -u root
echo "CREATE USER 'rma'@'localhost';  grant all ON *.* TO  'rma'@'localhost'  WITH GRANT OPTION; " |mysql -u root
