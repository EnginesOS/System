#!/bin/sh

mkdir -p /engines/var/run/flags

PID_FILE=/var/run/mysqld/mysqld.pid

export PID_FILE
. /home/trap.sh

 	
 if test -f /home/firstrun.sh 
	 then
        bash /home/firstrun.sh 
        mv /home/firstrun.sh /home/mysql/firstrun.sh.save
fi

/usr/sbin/mysqld --defaults-file=/etc/mysql/my.cnf --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/mysql/plugin --user=mysql --log-error=/var/log/mysql/error.log --pid-file=/var/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock --port=3306 &
wait $!