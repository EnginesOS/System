#/bin/sh
 
 
 if test $# -ne 2
  then 
   echo "Usage:"
   echo "$0  service Provider"
   exit -1
 fi
   
   
 
 if test -d /opt/engines/run/services/$1
  then
 	rm -r /opt/engines/run/services/$1
 fi
 if ! test -d /opt/engines/run/services-available/$1/$2 
 	then
 		echo "Not such Service $1 from $2"
 		exit -1
 	fi
cp -r /opt/engines/run/services-available/$1/$2 /opt/engines/run/services/$1
chgrp -R containers /opt/engines/run/services/$1
chmod g+rwx /opt/engines/run/services/$1

