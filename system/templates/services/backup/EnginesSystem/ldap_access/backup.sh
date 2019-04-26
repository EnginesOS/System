#!/bin/sh
 
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
. $SCRIPTPATH/set_access_dn.sh

 if test -z $access_dn
  then
   echo access_dn cant be nill
   exit -1
  fi 
  
ldapsearch -D ${ldap_dn} -w ${ldap_password} -h ${LDAP_HOST} -b $access_dn 2> /dev/null


#ldapsearch -D ${ldap_dn} -w ${ldap_password} -h ${LDAP_HOST} -b ou=${ldap_ou},ou=${parent_engine},ou=Applications,ou=Containers,ou=Engines,dc=engines,dc=internal 
 