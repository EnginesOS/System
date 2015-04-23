#!/bin/sh

mkdir -p /engines/var/run/

/usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/mysql/plugin --user=mysql --log-error=/var/log/mysql/error.log --pid-file=/var/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock --port=3306
touch  /engines/var/run/startup_complete

trap "{kill -TERM `cat   /var/run/mysqld/mysqld.pid `}"

sleep 30
while test -f /var/run/mysqld/mysqld.pid
do
	  sleep 20
done


rm /engines/var/run/startup_complete