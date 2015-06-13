#!/bin/sh

mkdir -p /engines/var/run/flags

PID_FILE=/var/run/mysqld/mysqld.pid


if test -f $PID_FILE
 	then
 		echo "Warning stale $PID_FILE"
 		rm $PID_FILE
 	fi
 	
 if test -f /home/firstrun.sh 
	 then
        bash /home/firstrun.sh 
        mv /home/firstrun.sh /home/mysql/firstrun.sh.save
fi

exec /usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/mysql/plugin --user=mysql --log-error=/var/log/mysql/error.log --pid-file=/var/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock --port=3306