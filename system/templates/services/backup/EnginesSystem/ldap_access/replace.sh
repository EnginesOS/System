#!/bin/sh


SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
. $SCRIPTPATH/set_access_dn.sh
 if test -z $access_dn
  then
   echo access_dn cant be nill
   exit -1
  fi 
  

/home/engines/scripts/ldap/ldapdelete.sh "$access_dn"

 cat $SCRIPTPATH/add_access.ldif | while read LINE
      do
        eval echo "$LINE" >> $LDIF_FILE
      done
   cat $LDIF_FILE | /home/engines/scripts/ldap/ldapadd.sh  
   rm  $LDIF_FILE
  done
  

