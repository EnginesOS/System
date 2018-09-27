#!/bin/sh


  ldapsearch -D $ldap_dn -w $ldap_password -h $LDAP_HOST -b cn=$group_cn,ou=$CONTAINER_NAME,ou=Applications,ou=Groups,dc=engines,dc=internal 
 
