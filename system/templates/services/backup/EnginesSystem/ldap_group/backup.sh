#!/bin/sh
. /home/engines/functions/params_to_env.sh
params_to_env

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
. $SCRIPTPATH/set_group_dn.sh

ldapsearch -D ${ldap_dn} -w ${ldap_password} -h ${LDAP_HOST} -b $group_dn
 
