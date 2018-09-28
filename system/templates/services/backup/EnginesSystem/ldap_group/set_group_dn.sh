#!/bin/sh

if test $container_type = service
 then
  top=Services
 else
  top=Applications
fi    
group_dn="cn=${cn},ou=${CONTAINER_NAME},ou=$top,ou=Groups,dc=engines,dc=internal"