!/bin/bash

service_hash=$1

echo $1 >/home/configurators/saved/smarthost

. /home/engines/scripts/functions.sh

load_service_hash_to_environment


echo $1 |grep = >/dev/null
        if test $? -ne 0
        then
                exit
        fi

res="${1//[^:]}"
echo $res
fcnt=${#res}
fcnt=`expr $fcnt + 1`

        while test $fcnt -ge $n
        do
                nvp="`echo $1 |cut -f$n -d:`"
                n=`expr $n + 1`
                name=`echo $nvp |cut -f1 -d=`
                export $name=`echo $nvp |cut -f2 -d=`
        done
        
        
   	if test  ${#smarthost_hostname} -gt 5
	then 
		if test 1 -lt ${#smarthost_port}
			then
				smarthost_port=25
		    fi

		echo "*	smtp:$smarthost_hostname:$smarthost_port"  > /etc/postfix/transport
		else
			echo "*	smtp:"  > /etc/postfix/transport
		fi 
		#chown root.root /etc/postfix/transport
		chmod 600 /etc/postfix/transport
		sudo postmap /etc/postfix/transport




 
 if test -n $mail_name
 then
 	echo $mail_name > /etc/postfix/mailname
 
 fi
 
 if test -z $smarthost_username -a -z $smarthost_password
 then 
   rm    smarthost_passwd.db smarthost_passwd
 	exit
 fi
 
 if test -z $smarthost_password
 then 
 	exit
 fi

echo "$smarthost_hostname $smarthost_username:$smarthost_password" > /etc/postfix/smarthost_passwd
#chown  /etc/postfix/smarthost_passwd
chmod 600 /etc/postfix/smarthost_passwd
sudo postmap   /etc/postfix/smarthost_passwd     