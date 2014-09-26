#!/bin/sh

//FIXME this is a kludge
 if test -f /home/fs.env
	then 
		. /home/fs.env
 chown -R www-data /home/app/fs/$VOLDIR

	fi

chown -R www-data  /home/app

/etc/init.d/apache2 start

check=0
	if test -f /home/blocking.sh
		then
			bash /home/blocking.sh
	else		

tail -f /var/log/apache2/error.log &

		while test $check -lt 1
        		do
        			sleep 100
        			status=`/etc/init.d/apache2 status`
				check=` echo $status |grep NOT |wc -c`
        done
fi

$0 &

