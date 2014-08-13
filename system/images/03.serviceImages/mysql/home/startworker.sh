#!/bin/sh

/etc/init.d/ssh start

 cat /etc/mysql/my.cnf |sed "/127.0.0.1/s//0.0.0.0/" >/etc/mysql/my.cnf.sed
mv /etc/mysql/my.cnf.sed /etc/mysql/my.cnf
/etc/init.d/mysql start

while test -f /var/run/mysqld/mysqld.pid
do
	  sleep 20
done


