#!/bin/sh


sudo syslogd -R syslog.engines.internal:5140

#No need as uses exec
#PIDFILE=/var/run/ftpd.pid
#source /home/trap.sh

mkdir -p /engines/var/run/
	touch  /engines/var/run/startup_complete
	chown 21000 /engines/var/run/startup_complete	
	
service_hash=`fg`


n=1

echo $service_hash |grep = >/dev/null
        if test $? -ne 0
        then
        		echo Error:No Arguments
                exit -1
        fi

#Strip preceeding and trailing :
new=`echo $service_hash | sed "/^:/s///" |  sed "/:$/s///"`
echo new
echo $new
service_hash=$new



fcnt=`echo $service_hash| grep -o : |wc -l`
echo $res
#fcnt=${#res}
fcnt=`expr $fcnt + 1`

        while test $fcnt -ge $n
        do
                nvp="`echo $service_hash |cut -f$n -d:`"
                n=`expr $n + 1`
                name=`echo $nvp |cut -f1 -d=`
                value=`echo $nvp |cut -f2 -d=`
                if test ${#name} -gt 0
                	then
                		export $name="$value"
                	fi
        done

	echo "	SQLConnectInfo $database_name@$db_host $db_username $db_password " >> /etc/proftpd/sql.conf
	echo  "</IfModule> " >> /etc/proftpd/sql.conf


exec sudo /usr/sbin/proftpd -n


rm /engines/var/run/startup_complete