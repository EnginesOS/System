#/bin/bash

n=1

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

	if test -z $smarthost_port
	then
		smarthost_port=25
	fi
	
	 #smarthost_hostname"=>"203.14.203.141", "smarthost_username"=>"", "smarthost_password"=>"", "smarthost_authtype"=>"", "smarthost_port"=>"", 
	if test -n $smarthost_hostname
	then 
		echo "*	$smarthost_hostname:$smarthost_port" > > /etc/postfix/transport
		chown root.root /etc/postfix/transport
		chmod 600 /etc/postfix/transport
fi


if test -z $smarthost_username
 then 
 	exit
 fi
 
 
 if test -z $smarthost_password
 then 
 	exit
 fi

echo "$smarthost_hostname $smarthost_username:$smarthost_password" > /etc/postfix/smarthost_passwd
chown root.root /etc/postfix/smarthost_passwd
chmod 600 /etc/postfix/smarthost_passwd
postmap   /etc/postfix/smarthost_passwd