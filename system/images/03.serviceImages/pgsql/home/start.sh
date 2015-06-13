#!/bin/sh

mkdir -p /engines/var/run/flags

PID_FILE=/var/run/postgresql/9.3-main.pid


if test -f $PID_FILE
 	then
 		echo "Warning stale $PID_FILE"
 		rm $PID_FILE
 	fi
 	
 	
trap_term()
{
	if test -f $PID_FILE
	then
		kill -TERM `cat   $PID_FILE `
		echo touch /engines/var/run/flags/termed
	fi
}
trap_hup()
{
if test -f $PID_FILE
	then
		kill -HUP `cat   $PID_FILE `
		echo touch /engines/var/run/flags/huped
	fi
}
trap_quit()
{
if test -f $PID_FILE
	then
		kill -QUIT `cat   $PID_FILE `
		echo touch /engines/var/run/flags/quited
	fi
}

trap trap_term  15
trap trap_hup 1
trap trap_quit 3

 if test -f /home/firstrun.sh 
	 then
        bash /home/firstrun.sh 
        cp /home/firstrun.sh /home/postgres/firstrun.sh.save
fi

exec /usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf