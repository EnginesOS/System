#/bin/bash


host=`echo $1 |cut -f1`
port=`echo $1 |cut -f2`
	if test -z port
	then
		port=25
	fi
	
echo "*	$host:$port" > > /etc/postfix/transport
chown root.root /etc/postfix/transport
chmod 600 /etc/postfix/transport

user=`echo $1 |cut -f3`
pass=`echo $1 |cut -f4`
if test -z $user
 then 
 exit
 fi
 
 
 if test -z $pass
 then 
 exit
 fi

echo "$host $user:$pass" > /etc/postfix/smarthost_passwd
chown root.root /etc/postfix/smarthost_passwd
chmod 600 /etc/postfix/smarthost_passwd
postmap      /etc/postfix/smarthost_passwd