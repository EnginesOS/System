#!/bin/sh


sudo syslogd -R syslog.engines.internal:5140

#No need as uses exec
#PIDFILE=/var/run/ftpd.pid
#source /home/trap.sh

mkdir -p /engines/var/run/
	touch  /engines/var/run/startup_complete
	chown 21000 /engines/var/run/startup_complete	
	
service_hash=`ssh -p 2222  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/.ssh/access_rsa auth@auth.engines.internal /home/auth/access/ftp/get_access.sh`


. /home/engines/scripts/functions.sh

load_service_hash_to_environment
	
	echo "
	SQLConnectInfo $db_username@$db_host $db_username $db_password
</IfModule> 
" >> /etc/proftpd/sql.conf

exec sudo /usr/sbin/proftpd -n


rm /engines/var/run/startup_complete