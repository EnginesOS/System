#!/bin/sh

echo rm_ftp_service.sh
TS=` date +%Y%m%d%H%M%S`
echo $TS: $SSH_ORIGINAL_COMMAND >> /var/log/ftp/rm.log

cat - | /home/engines/bin/json_to_env >/tmp/.env
 . /tmp/.env
               
        if test "$rw_access" = "true"
          then
          	access="rw"
          else
          	access="ro"
        fi
        set

     
        . /home/auth/.dbenv
         sql="update users set use_count = use_count - 1,ftphomedir='' where userid = '$username';"  
         echo $sql | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
        
         echo $sql   mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname> /tmp/.db
        
         sql="delete from users where use_count<=0 and  userid = '$username';"  
         echo $sql | mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname
        
        echo $sql   mysql -h $dbhost -u $dbuser --password=$dbpasswd $dbname >> /tmp/.db
        