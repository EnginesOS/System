#!/bin/sh
 
ldapsearch -D $ldap_dn -w $ldap_password -h $LDAP_HOST -b ou=$ldap_ou,ou=$CONTAINER_NAME,ou=Applications,ou=Containers,ou=Engines,dc=engines,dc=internal 
 