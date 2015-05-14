#!/bin/sh

echo add_ftp_service.sh
TS=` date +%Y%m%d%H%M%S`
echo $TS: $SSH_ORIGINAL_COMMAND >> /var/log/ftp/add.log


new=`echo $service_hash | sed "/^:/s///" |  sed "/:$/s///"`

service_hash=$new



fcnt=`echo $service_hash| grep -o : |wc -l`

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
        
        access="ro"
         if test $rw_access = 'true'
          then
          	access="rw"
        fi
        pass=`/bin/echo -n "$password" | openssl dgst -binary -md5 | openssl enc -base64`
        sql="insert into users (userid,passwd,homedir) values('$username','{md5}$pass','/ftp/$access/$parent_engine/$volume/$folder/')
        echo $sql | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
        echo $sql   mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname