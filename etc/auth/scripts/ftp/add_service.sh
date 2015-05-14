#!/bin/sh

echo add_ftp_service.sh
TS=` date +%Y%m%d%H%M%S`
echo $TS: $SSH_ORIGINAL_COMMAND >> /var/log/ftp/add.log

service_hash=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $2}'`
echo $service_hash
new=`echo $service_hash | sed "/^:/s///" |  sed "/:$/s///"`

service_hash=$new


n=1

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
                
         if test "$rw_access" = "true"
          then
          	access="rw"
          else
          	access="ro"
        fi
     
        pass=`/bin/echo -n "$password" | openssl dgst -binary -md5 | openssl enc -base64`
        sql="insert into users (userid,passwd,ftphomedir,use_count) values('$username','{md5}$pass','/ftp/$access/$parent_engine/$volume/$folder/',0)"
        
        . /home/auth/.dbenv
        echo $sql | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
        echo $sql   mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
        
           sql="update users set use_count = 1 + use_count,ftphome='/ftp/$access/$parent_engine/$volume/$folder/' where userid = '$username';"  
               
         echo $sql | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
         echo $sql   mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname