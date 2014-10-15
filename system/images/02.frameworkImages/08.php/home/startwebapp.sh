#!/bin/sh

#//FIXME this is a kludge
 if test -f /home/fs.env
	then 
		. /home/fs.env
 chown -R www-data /home/app/fs/$VOLDIR

	fi
	
rm -f /var/run/apache2/apache2.pid 
chown -R www-data  /home/app
echo Starting Apache
/etc/init.d/apache2 start

touch /var/run/startup_complete
chown 21000 /var/run/startup_complete

check=0
	if test -f /home/blocking.sh
		then
			bash /home/blocking.sh
	else		



		while test $check -lt 1
        		do
        			sleep 100
        			status=`/etc/init.d/apache2 status`
				check=` echo $status |grep NOT |wc -c`
        done
fi

$0 &

