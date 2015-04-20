#!/bin/bash

service_hash=$1

. /home/engines/scripts/functions.sh

load_service_hash_to_environment

BTICK='`'

E_BADARGS=65
MYSQL=`which mysql`

if test -z $database_name
	then
		echo Error:No database_name value
		exit -1
	fi
	
if test -z $db_username
	then
		echo Error:No db_username value
		exit -1
	fi
		
if test -z $db_password
	then
		echo Error:No db_password value
		exit -1
	fi
	
if test -z $collation
	then
		echo Error:No collation value
		exit -1
	fi
	
echo  "CREATE ROLE $db_username WITH ENCRYPTED PASSWORD '$db_password'  LOGIN;" >/tmp/.c.sql
echo "CREATE DATABASE $database_name OWNER = $db_username ;" >> /tmp/.c.sql
echo "alter  ROLE $db_username login; " >> /tmp/.c.sql


#echo "$SQL"

su postgres -c psql < /tmp/.c.sql

if test $? -ge 0
	then 
		echo "Success"
		rm /tmp/.c.sql
		exit 0
	fi
	
	echo "Error:"
	exit -1
	

