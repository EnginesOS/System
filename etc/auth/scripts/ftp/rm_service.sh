#!/bin/sh

echo rm_ftp_service.sh
TS=` date +%Y%m%d%H%M%S`
echo $TS: $SSH_ORIGINAL_COMMAND >> /var/log/ftp/rm.log

#service_hash=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $2}'`
#echo $service_hash
#new=`echo $service_hash | sed "/^:/s///" |  sed "/:$/s///"`

#service_hash=$new
cat - > /tmp/.sh
service_hash=`cat /tmp/.sh`
rm /tmp/.sh
 echo \'$service_hash\' | /home/engines/bin/json_to_env >/tmp/.env
 . /tmp/.env
#n=1
#
#fcnt=`echo $service_hash| grep -o : |wc -l`
#
#fcnt=`expr $fcnt + 1`
#
#        while test $fcnt -ge $n
#        do
#                nvp="`echo $service_hash |cut -f$n -d:`"
#                n=`expr $n + 1`
#                name=`echo $nvp |cut -f1 -d=`
#                value=`echo $nvp |cut -f2 -d=`
#                if test ${#name} -gt 0
#                	then
#                		export $name="$value"
#                	fi
#        done
#                
#         if test "$rw_access" = "true"
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
        