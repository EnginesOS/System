#!/bin/sh

mkdir -p /engines/var/run/flags

PID_FILE=/var/run/postgresql/9.3-main.pid
export PID_FILE
. /home/trap.sh


 if test -f /home/firstrun.sh 
	 then
        bash /home/firstrun.sh 
        cp /home/firstrun.sh /home/postgres/firstrun.sh.save
fi

 /usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf &
 wait $!
