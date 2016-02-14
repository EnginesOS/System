#!/bin/sh

echo add_ftp_service.sh
TS=` date +%Y%m%d%H%M%S`
mkdir -p /var/log/ftp/
echo $TS: $SSH_ORIGINAL_COMMAND >> /var/log/ftp/add.log

service_hash=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $2}'`
echo $service_hash


 echo $service_hash | /home/engines/bin/json_to_env >/tmp/.env
 . /tmp/.env


n=1


                
         if test "$rw_access" = "true"
          then
          	access="rw"
          else
          	access="ro"
        fi
     
 
        pass=`/bin/echo -n "$password" | openssl dgst -binary -md5 | openssl enc -base64`
        sql="insert into users (userid,passwd,gid,ftphomedir,use_count) values('$username','{md5}$pass',${ftp_gid},'/ftp/$access/$parent_engine/$volume/$folder/',0)"
        
        . /home/auth/.dbenv
        echo $sql | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
        echo $sql   mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
        
           sql="update users set use_count = 1 + use_count,ftphomedir='/ftp/$access/$parent_engine/$volume/$folder/' where userid = '$username';"  
               
         echo $sql | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
         echo $sql   mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname