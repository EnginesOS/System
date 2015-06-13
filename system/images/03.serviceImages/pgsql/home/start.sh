#!/bin/sh

mkdir -p /engines/var/run/flags

PID_FILE=/var/run/postgresql/9.3-main.pid


if test -f $PID_FILE
 	then
 		echo "Warning stale $PID_FILE"
 		rm $PID_FILE
 	fi
 	
 if test -f /home/firstrun.sh 
	 then
        bash /home/firstrun.sh 
        cp /home/firstrun.sh /home/postgres/firstrun.sh.save
fi

exec /usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf